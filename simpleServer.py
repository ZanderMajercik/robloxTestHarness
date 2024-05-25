import keyboard
import time
# from flask import Flask

# jsonString = "{\"key\": \"a\"}"

# app = Flask(__name__)
# key = "b"

# @app.route("/index.json")
# def hello_world():
#     # TODO: restore, always return a while debugging.
#     return "{\"key\": \"a\"}"
#     #jsonString.replace("a", keyboard.read_key())


from pyKey import pressKey, releaseKey, press, sendSequence, showKeys


toPyKey = {
    "a" : "A",
    "s" : "S",
    "d" : "D",
    "f" : "F",
    "space" : "SPACEBAR"
}

time.sleep(4)

print("Space Down")
pressKey("SPACEBAR")
time.sleep(1)
releaseKey("SPACEBAR")
print("Space UP")


#while True:
#    #key = keyboard.read_key()
#    pressKey("SPACEBAR")
#    releaseKey("SPACEBAR")
#    #jsonString = jsonString
#    #with open("index.json", "w") as f:
#    #    f.write(jsonString.replace("a", keyboard.read_key()))
#    if keyboard.read_key() == "v":
#        break


#while True:
#    key = keyboard.read_key()
#    print(key)
#    #jsonString = jsonString
#    #with open("index.json", "w") as f:
#    #    f.write(jsonString.replace("a", keyboard.read_key()))
#    if keyboard.read_key() == "a":
#        break
