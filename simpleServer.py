import keyboard
import time
from flask import Flask
from flask import request, jsonify
import json
from multiprocessing import Process, Value


jsonString = "{\"key\": \"a\"}"

app = Flask(__name__)

controlDict = {
    "w" : "up",
    "a" : "up",
    "s" : "up",
    "d" : "up",
    "space" : "up"
}

# @app.route('/', methods=['GET', 'POST'])
# def parse_request():
#     data = request.data  # data is empty
#     # need posted data here

@app.route("/index.json", methods=['POST'])
def receiveObservations():
    data = request.get_json()
    for key in data.keys():
        print(key, ":", data[key])
    return data


@app.route("/index.json", methods=['GET'])
def sendKeyState():
    #return "{\"key\": \"d\"}"
    for k in controlDict.keys():
        controlDict[k] = "down" if keyboard.is_pressed(k) else "up"
    shouldStep = "False"
    for k in controlDict.keys():
        if controlDict[k] == "down":
            shouldStep = "True"
    sendDict = controlDict.copy()
    sendDict["shouldStep"] = shouldStep
    return json.dumps(sendDict)


    #jsonString = jsonString
    #with open("index.json", "w") as f:
    #    f.write(jsonString.replace("a", keyboard.read_key()))
    #if keyboard.read_key() == "a":
    #    break
#if __name__ == "__main__":
#   p = Process(target=record_keypress)
#   p.start()  
#   app.run(debug=True, use_reloader=False)
#   p.join()


# Pykey library from here: https://github.com/gauthsvenkat/pyKey/tree/master
# If we were doing pixels to actions, this could work
# Pixels to actions sync is a problem in either case.
# from pyKey import pressKey, releaseKey, press, sendSequence, showKeys


# toPyKey = {
#     "a" : "A",
#     "s" : "S",
#     "d" : "D",
#     "f" : "F",
#     "space" : "SPACEBAR"
# }

# time.sleep(4)

# print("Space Down")
# pressKey("SPACEBAR")
# time.sleep(1)
# releaseKey("SPACEBAR")
# print("Space UP")


#while True:
#    #key = keyboard.read_key()
#    pressKey("SPACEBAR")
#    releaseKey("SPACEBAR")
#    #jsonString = jsonString
#    #with open("index.json", "w") as f:
#    #    f.write(jsonString.replace("a", keyboard.read_key()))
#    if keyboard.read_key() == "v":
#        break

@app.route("/get_obby_json", methods=['GET', 'POST'])
def get_obby_json():
    data = request.get_json()
    filename = data.get('filename')
    obby_json = json.load(open(f'src/server/json/{filename}'))
    return jsonify(obby_json)