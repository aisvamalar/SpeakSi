import pyttsx3

def text_to_speech_pyttsx3(text):
   
    engine = pyttsx3.init()
    
    
    engine.setProperty('rate', 150)  
    engine.setProperty('volume', 1)  
    engine.say(text)
    engine.runAndWait()


text = "charan"
text_to_speech_pyttsx3(text)
