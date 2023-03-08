from csv import excel
import json
import re
import threading
import tkinter as tk
from tkinter import filedialog as fd

# Imports to install
# > pip install pandas openpyxl
import pandas as pd


# Constants
JSON_FILE_NAME = "/risks-data.json"
IMAGE_FILE_FORMAT = ".png"
IMAGE_FILES_PATH = "assets/images-sst/"

RISKS_SHORTNAMES = {
    1: ["chemical", "c"],
    2: ["biological", "b"],
    3: ["equipment", "e"],
    4: ["fall", "f"],
    5: ["objectFall","of"],
    6: ["transit", "t"],
    7: ["posture", "p"],
    8: ["motion", "mv"],
    9: ["handling", "h"],
    10: ["psychological", "psy"],
    11: ["noise", "n"],
    12: ["temperature", "et"],
    13: ["vibration", "v"],
    14: ["electric", "el"],
    15: ["anoxia", "a"],
    16: ["fire", "fi"],
    17: ["nanomaterial", "nm"],
}


# Main functions


def run():
    '''Run the main script in a new thread'''

    def target():
        entrySST["state"] = "disabled"
        entryStage["state"] = "disabled"
        fileButtonSST["state"] = "disabled"
        fileButtonStage["state"] = "disabled"
        startButton["state"] = "disabled"
        start(excelPathSST.get())
        entrySST["state"] = "normal"
        entryStage["state"] = "normal"
        fileButtonSST["state"] = "normal"
        fileButtonStage["state"] = "normal"
        startButton["state"] = "normal"

    threading.Thread(target=target).start()


def start(excelPathSST: str):
    '''Starts the main script'''
    try:
        excelSST = pd.read_excel(excelPathSST)
    except FileNotFoundError:
        setMessage("Fichier Excel invalide")
        return

    json = []

    for index in excelSST.index:
        row = excelSST.loc[index]

        json.append({
            "number": str(row[0]),
            "shortname": RISKS_SHORTNAMES[int(row[0])][0],
            "abbrv": RISKS_SHORTNAMES[int(row[0])][1],
            "name": str(row[1]),
            "subrisks": [
                    {
                        "number": "1" if str(row[9]) != "nan" else "0",
                        "title": str(row[2]) if str(row[2]) != "nan" else "",
                        "intro": str(row[3]),
                        # the DataFrame format return "NaN" if the cell is empty
                        "situations": createDictFromString(row[4]) if str(row[4]) != "nan" else [],
                        "factors": createDictFromString(row[5]) if str(row[5]) != "nan" else [],
                        "symptoms": createDictFromString(row[6]) if str(row[6]) != "nan" else [],
                        "images": [IMAGE_FILES_PATH + str(int(row[7])) + IMAGE_FILE_FORMAT if str(row[7]) != "nan" else None,
                                   IMAGE_FILES_PATH + str(int(row[8])) + IMAGE_FILE_FORMAT if str(row[8]) != "nan" else None]
                    },
                    {
                        "number": "2",
                        "title": str(row[9]) if str(row[9]) != "nan" else "",
                        "intro": str(row[10]),
                        "situations": createDictFromString(row[11]) if str(row[11]) != "nan" else [],
                        "factors": createDictFromString(row[12]) if str(row[12]) != "nan" else [],
                        "symptoms": createDictFromString(row[13]) if str(row[13]) != "nan" else [],
                        "images": [IMAGE_FILES_PATH + str(int(row[14])) + IMAGE_FILE_FORMAT if str(row[14]) != "nan" else None,
                                   IMAGE_FILES_PATH + str(int(row[15])) + IMAGE_FILE_FORMAT if str(row[15]) != "nan" else None]
                    } if str(row[9]) != "nan" else None
                    ],
            "links": [
                {
                    "source": str(row[16]),
                    "title": str(row[17]),
                    "url": str(row[18])
                },
                {
                    "source": str(row[19]),
                    "title": str(row[20]),
                    "url": str(row[21])
                } if str(row[19]) != "nan" else None,
                {
                    "source": str(row[22]),
                    "title": str(row[23]),
                    "url": str(row[24])
                } if str(row[22]) != "nan" else None,
                {
                    "source": str(row[25]),
                    "title": str(row[26]),
                    "url": str(row[27])
                } if str(row[25]) != "nan" else None
            ]
        }
        )

    saveJson(json, jsonPath.get() + JSON_FILE_NAME)
    setMessage("Tout est fini!")


def createDictFromString(cell: pd.DataFrame):
    riskTypeDict = []
    index = -1
    for line in str(cell).split("\n")[::1]:
        if line[0] == "-":
            riskTypeDict[index]["sublines"].append(line[1:].strip())
        else:
            riskTypeDict.append({"line": line,
                                  "sublines": [], })
            index += 1

    return riskTypeDict


def cleanUpText(text: str):
    '''Removes unwanted formating chars at the end of [text].'''
    text = re.match(r"[^\t\r\n]*", text).group(0)
    text = text.replace("\u009c", "oe")
    text = text.replace("\u0092", "'")
    return text


def cleanUpData(data):
    if isinstance(data, list):
        return [cleanUpData(x) for x in data if x is not None]
    elif isinstance(data, dict):
        return {key: cleanUpData(val) for key, val in data.items() if val is not None}
    elif isinstance(data, str):
        return cleanUpText(data)
    else:
        return data


# Utils
def saveJson(data: dict, path: str):
    '''Saves [json] as a file named [path] formated with an indent of 4.'''
    setMessage("Saving json...")
    with open(path, "w") as file:
        file.write(json.dumps(cleanUpData(data),
                   indent=0, separators=(',', ':')))


def setMessage(message: str):
    print(message)
    currentMessage.set(message)


def askExcelPath():
    file = fd.askopenfile(title="Choisir un classeur Excel", filetypes=(
        ("Classeurs Excel", "*.xlsx *.xls"), ("Tous les fichiers", "*.*")))

    if (file is not None):
        return file.name
    else:
        return ""

def askPath():
    path = fd.askdirectory(title="Choisir un chemin d'accès")

    if (path is not None):
        return path
    else:
        return ""

# Tkinter initialisation
root = tk.Tk()
root.title("CRCRME - Générer répertoire métiers")
root.geometry("450x200")
root.resizable(False, False)
mainFrame = tk.Frame(root)
mainFrame.pack(padx=20, pady=20)

# Excel table needs to respect a certain format
tk.Label(mainFrame, text="Entrez le chemin d'accès du classeur Excel contenant les informations SST.").pack()

frame = tk.Frame(mainFrame)
frame.pack()

excelPathSST = tk.StringVar(
    value="Contenu_fiches_SST.xlsx")
entrySST = tk.Entry(frame, textvariable=excelPathSST)
entrySST.focus()
entrySST.pack(side="left")

fileButtonSST = tk.Button(frame, text="Parcourir",
                          command=lambda: excelPathSST.set(askExcelPath()))
fileButtonSST.pack(side="right")

tk.Label(mainFrame, text="Entrez le chemin d'accès où stocker les données de risques.").pack()

frame = tk.Frame(mainFrame)
frame.pack()

jsonPath = tk.StringVar(value="assets")
entryStage = tk.Entry(frame, textvariable=jsonPath)
entryStage.pack(side="left")

fileButtonStage = tk.Button(frame, text="Parcourir",
                            command=lambda: jsonPath.set(askPath()))
fileButtonStage.pack(side="right")


startButton = tk.Button(mainFrame, text="Générer", command=run)
startButton.pack(side="bottom")

currentMessage = tk.StringVar()
messageLabel = tk.Label(mainFrame, textvariable=currentMessage)
messageLabel.pack(side="bottom")


if __name__ == "__main__":
    root.mainloop()

