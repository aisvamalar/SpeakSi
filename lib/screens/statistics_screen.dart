import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/animation.dart';
import 'package:shimmer/shimmer.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> statisticsData = [];
  List<_ChartData> chartData = [];
  String selectedTimeRange = 'Overall';
  bool isLoading = true;
  bool isRefreshing = false;

  int totalWords = 0;
  double spellSuccessRate = 0.0;
  double accuracyTargetPercentage = 0.0;
  double weeklyImprovementPercentage = 0.0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchInitialData();
    _setupRealtimeSubscription();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _fetchInitialData() async {
    setState(() => isLoading = true);
    await fetchStatistics();
    setState(() => isLoading = false);
    _animationController.forward();
  }

  void _setupRealtimeSubscription() {
    supabase.from('score_base').stream(primaryKey: ['id']).listen((event) async {
      setState(() => isRefreshing = true);
      await fetchStatistics();
      setState(() => isRefreshing = false);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchStatistics() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        print("User not logged in.");
        return;
      }

      final response = await supabase
          .from('score_base')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: true);

      if (response != null && response.isNotEmpty) {
        setState(() {
          statisticsData = response.map((record) => {
            'word': record['word'],
            'similarity': record['similarity_score'],
            'mismatched_letters': record['mismatched_letters'],
            'timestamp': record['created_at'],
            'user_id': record['user_id']
          }).toList();

          _prepareChartData(selectedTimeRange);
          _calculateMetrics();
        });
      }
    } catch (error) {
      print('Error fetching statistics: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch statistics. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _prepareChartData(String timeRange) {
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> filteredData = [];

    try {
      switch (timeRange) {
        case 'Last Hour':
          filteredData = statisticsData.where((stat) {
            DateTime timestamp = DateTime.parse(stat['timestamp']);
            return now.difference(timestamp).inHours <= 1;
          }).toList();
          break;
        case 'Last 3 Hours':
          filteredData = statisticsData.where((stat) {
            DateTime timestamp = DateTime.parse(stat['timestamp']);
            return now.difference(timestamp).inHours <= 3;
          }).toList();
          break;
        default: // Overall
          filteredData = statisticsData;
      }

      Map<String, List<double>> groupedData = {};
      for (var stat in filteredData) {
        DateTime timestamp = DateTime.parse(stat['timestamp']);
        String intervalKey = _getIntervalKey(timestamp, timeRange);
        double similarity = (stat['similarity'] as num).toDouble();

        if (!groupedData.containsKey(intervalKey)) {
          groupedData[intervalKey] = [];
        }
        groupedData[intervalKey]!.add(similarity);
      }

      setState(() {
        selectedTimeRange = timeRange;
        chartData = groupedData.entries.map((entry) {
          double averageAccuracy = entry.value.reduce((a, b) => a + b) / entry.value.length;
          return _ChartData(entry.key, averageAccuracy);
        }).toList();
      });
    } catch (error) {
      print("Error processing chart data: $error");
    }
  }

  String _getIntervalKey(DateTime timestamp, String timeRange) {
    if (timeRange == 'Last Hour' || timeRange == 'Last 3 Hours') {
      int minute = timestamp.minute >= 30 ? 30 : 0;
      return DateFormat('HH:mm').format(DateTime(timestamp.year, timestamp.month, timestamp.day, timestamp.hour, minute));
    } else {
      return DateFormat('MMM dd').format(timestamp);
    }
  }

  void _calculateMetrics() {
    if (statisticsData.isEmpty) return;

    int successfulWords = 0;
    double totalAccuracy = 0;
    int count = 0;

    DateTime oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    double pastWeekAccuracy = 0;
    int pastWeekCount = 0;

    for (var stat in statisticsData) {
      double similarity = (stat['similarity'] as num).toDouble();

      if (similarity >= 73) {
        successfulWords++;
      }

      totalAccuracy += similarity;
      count++;

      DateTime timestamp = DateTime.parse(stat['timestamp']);
      if (timestamp.isAfter(oneWeekAgo)) {
        pastWeekAccuracy += similarity;
        pastWeekCount++;
      }
    }

    setState(() {
      totalWords = statisticsData.length;
      spellSuccessRate = totalWords > 0 ? (successfulWords / totalWords) * 100 : 0.0;
      accuracyTargetPercentage = count > 0 ? totalAccuracy / count : 0.0;
      weeklyImprovementPercentage = pastWeekCount > 0
          ? ((accuracyTargetPercentage - (pastWeekAccuracy / pastWeekCount)) /
          accuracyTargetPercentage) *
          100
          : 0.0;
    });
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.deepPurple.shade900,
      highlightColor: Colors.purple.shade700,
      child: Column(
        children: [
          Container(
            height: 60,
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
          ),
          Container(
            height: 50,
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
          ),
          Container(
            height: 300,
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            padding: EdgeInsets.all(16),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: List.generate(6, (index) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshIndicator({required Widget child}) {
    return Stack(
      children: [
        child,
        if (isRefreshing)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Refreshing...',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade800, Colors.purple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "Keep up the great work! Your progress is amazing.",
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ['Overall', 'Last Hour', 'Last 3 Hours'].map((range) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: selectedTimeRange == range ? Colors.amber : Colors.deepPurple.shade800,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedTimeRange = range;
                      _prepareChartData(range);
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      range,
                      style: TextStyle(
                        color: selectedTimeRange == range ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade800, Colors.purple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(
          labelStyle: TextStyle(color: Colors.white),
          axisLine: AxisLine(color: Colors.white),
          majorGridLines: MajorGridLines(width: 0),
          labelRotation: 45,
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          maximum: 100,
          interval: 10,
          labelStyle: TextStyle(color: Colors.white),
          axisLine: AxisLine(color: Colors.white),
          majorGridLines: MajorGridLines(color: Colors.white.withOpacity(0.2)),
        ),
        series: <ChartSeries>[
          ColumnSeries<_ChartData, String>(
            dataSource: chartData,
            xValueMapper: (_ChartData data, _) => data.date,
            yValueMapper: (_ChartData data, _) => data.score,
            name: 'Accuracy',
            color: Colors.amber,
            width: 0.8,
            spacing: 0.2,
            borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
            gradient: LinearGradient(
              colors: [Colors.amber, Colors.amber.shade600],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.top,
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        tooltipBehavior: TooltipBehavior(
          enable: true,
          format: 'Accuracy: point.y%',
          color: Colors.deepPurple.shade800,
          textStyle: TextStyle(color: Colors.white),
        ),
        plotAreaBorderWidth: 0,
        palette: <Color>[Colors.amber],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    List<Widget> cards = [
      _buildStatCard("Total Words", "$totalWords", Icons.text_fields),
      _buildStatCard("Spell Success %", "${spellSuccessRate.toStringAsFixed(2)}%", Icons.spellcheck),
      _buildStatCard("Accuracy Target %", "${accuracyTargetPercentage.toStringAsFixed(2)}%", Icons.track_changes),
      _buildStatCard("Weekly Improvement %", "${weeklyImprovementPercentage.toStringAsFixed(2)}%", Icons.trending_up),
      _buildStatCard("Average Daily Accuracy", "85.5%", Icons.bar_chart),
      _buildStatCard("Best Performance Time", "10:00 AM", Icons.access_time),
    ];

    return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
    ),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade800, Colors.purple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.amber, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade800, Colors.purple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "Tip: Practice daily to see consistent improvement in your accuracy!",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() => isRefreshing = true);
            await fetchStatistics();
            setState(() => isRefreshing = false);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 50,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Statistics',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple.shade900, Colors.purple.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                pinned: true,
                backgroundColor: Colors.deepPurple.shade900,
              ),
              SliverToBoxAdapter(
                child: isLoading
                    ? _buildLoadingShimmer()
                    : _buildRefreshIndicator(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 20),
                            _buildTimeRangeSelector(),
                            const SizedBox(height: 20),
                            _buildChartSection(),
                            const SizedBox(height: 20),
                            _buildStatisticsCards(),
                            const SizedBox(height: 20),
                            _buildFooter(),
                            // Add extra padding at the bottom for better scroll experience
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartData {
  final String date;
  final double score;

  _ChartData(this.date, this.score);
}