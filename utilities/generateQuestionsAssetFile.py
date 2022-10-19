import json
import math
import re
import tkinter as tk
from tkinter import filedialog as fd

# Imports to install
# > pip install pandas openpyxl
import pandas as pd

# Constants
JSON_FILE_PATH = "assets/questions.json"

# Data to change
EXCEL_DATA_HEADERS = {
    # json : excel
    "id": "Question ID",
    "qp": "Question Professeur",
    "qs": "Question Élève",
    "t": "Type de réponse",
    "c": "Choix de réponses",
    "sp": "Sous-question Professeur",
    "ss": "Sous-question Élève",
}


# Main functions
def run():
    '''Starts the main script'''
    try:
        excel = pd.read_excel(excelPath.get())
    except FileNotFoundError:
        setMessage("Fichier Excel invalide")
        return

    json = []
    for _, row in excel.iterrows():
        question = {}
        for name, excelHeader in EXCEL_DATA_HEADERS.items():
            if excelHeader == "Choix de réponses":
                if type(row[excelHeader]) is str:
                    question[name] = str(row[excelHeader]).splitlines()

            elif type(row[excelHeader]) is str or not math.isnan(row[excelHeader]):
                question[name] = str(row[excelHeader])
        json.append(question)

    saveJson(json, JSON_FILE_PATH)
    setMessage("Tout est fini!")


# String processing
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
    '''Saves [json] as a file named [path].'''
    setMessage("Saving json...")
    with open(path, "w") as file:
        file.write(json.dumps(cleanUpData(data),
                   indent=0, separators=(',', ':')))


def setMessage(message: str):
    print(message)
    currentMessage.set(message)


def askExcelPath():
    file = fd.askopenfile(title="Choisir un classeur", filetypes=(
        ("Classeur Excel", "*.xlsx *.xls"), ("Tous les fichiers", "*.*")))

    if (file is not None):
        return file.name
    else:
        return ""


# Tkinter initialisation
root = tk.Tk()
root.title("CRCRME - Générer répertoire métiers")
root.geometry("450x200")
root.resizable(False, False)
mainFrame = tk.Frame(root)
mainFrame.pack(padx=20, pady=20)


tk.Label(mainFrame, text="Entrez le chemin d'accès du classeur Excel contenant les questions à poser.").pack()

frame = tk.Frame(mainFrame)
frame.pack()

excelPath = tk.StringVar()
excelEntry = tk.Entry(frame, textvariable=excelPath)
excelEntry.focus()
excelEntry.pack(side="left")

fileButtonExcel = tk.Button(frame, text="Parcourir",
                            command=lambda: excelPath.set(askExcelPath()))
fileButtonExcel.pack(side="right")


startButton = tk.Button(mainFrame, text="Générer", command=run)
startButton.pack(side="bottom")

currentMessage = tk.StringVar()
messageLabel = tk.Label(mainFrame, textvariable=currentMessage)
messageLabel.pack(side="bottom")


if __name__ == "__main__":
    root.mainloop()