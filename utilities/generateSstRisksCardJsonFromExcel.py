from csv import excel
import json
import re
import threading
import tkinter as tk
from tkinter import filedialog as fd

# Imports to install
# > pip install pandas requests bs4 openpyxl
import pandas as pd
import requests
from bs4 import BeautifulSoup



# Constants
JSON_FILE_PATH = "assets/risks-data-test.json"

EXCEL_SECTOR_HEADER = "N° secteur"
EXCEL_SPECIALIZATION_HEADER = "N° métiers"
EXCEL_SKILL_HEADER = "Numéro de compétences"

# Data to change
EXCEL_SST_DATA_HEADERS = {
    # json : excel
    "c": "1. Risques Chimiques",
    "b": "2. Risques Biologiques",
    "e": "3. Risques liés aux machines et aux équipements",
    "f": "4. Risques de chutes de hauteur et de plain-pied",
    "of": "5. Risques liés aux chutes d’objets",
    "t": " 6. Risques liés aux déplacements",
    "p": " 7. Risques liés aux postures contraignantes",
    "mv": "8. Risques liés aux mouvements répétitifs, pressions de contact et chocs",
    "h": "9. Risques liés à la manutention",
    "psy": "10. Risques psychosociaux et de violence",
    "n": "11. Risques liés au bruit",
    "et": "12. Risques liés à l'Froid et chaleur",
    "v": "13. Risques liés aux vibrations",
    "el": "14.1 Risques électriques",
    "a": "14.2 Risque anoxie et travail en espace clos",
    "fi": "14.3 Risque ATEX,  incendie ou explosion",
    "nm": "14.4 Risques nanomatériaux ",
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

    print(excelSST)

    for index in excelSST.index:
        row = excelSST.loc[index]
        json.append({
            str(row[0]): {
                "name": str(row[1]),
                "risks": {
                    "1": {
                        "title": str(row[2]),
                        "intro": str(row[3]),
                        "situations": str(row[4]).split("\n")[::1],
                    }
                }
            }
        })

    saveJson(json, JSON_FILE_PATH)
    setMessage("Tout est fini!")


# Excel readers
def getSSTDataFromExcel(excel: pd.DataFrame, sector, specialization, skill):
    '''Returns the corresponding data contained in the SST excel file'''
    result = []
    row = excel.loc[(excel[EXCEL_SECTOR_HEADER] == int(sector)) & (
        excel[EXCEL_SPECIALIZATION_HEADER] == int(specialization)) & (excel[EXCEL_SKILL_HEADER] == int(skill))]

    for name, excelHeader in EXCEL_SST_DATA_HEADERS.items():
        if row[excelHeader].index.size > 0 and row[excelHeader].get(row[excelHeader].index[0], "") == "oui":
            result.append(name)

    return result

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


# Tkinter initialisation
root = tk.Tk()
root.title("CRCRME - Générer répertoire métiers")
root.geometry("450x200")
root.resizable(False, False)
mainFrame = tk.Frame(root)
mainFrame.pack(padx=20, pady=20)


tk.Label(mainFrame, text="Entrez le chemin d'accès du classeur Excel contenant les informations SST.").pack()

frame = tk.Frame(mainFrame)
frame.pack()

excelPathSST = tk.StringVar(
    value="D:/Users/2061694/Documents/GitHub/ressources/Contenu_fiches_SST.xlsx")
entrySST = tk.Entry(frame, textvariable=excelPathSST)
entrySST.focus()
entrySST.pack(side="left")

fileButtonSST = tk.Button(frame, text="Parcourir",
                          command=lambda: excelPathSST.set(askExcelPath()))
fileButtonSST.pack(side="right")

tk.Label(mainFrame, text="Entrez le chemin d'accès où stocker les données de risques.").pack()

frame = tk.Frame(mainFrame)
frame.pack()

jsonPath = tk.StringVar(value=JSON_FILE_PATH)
entryStage = tk.Entry(frame, textvariable=jsonPath)
entryStage.pack(side="left")

fileButtonStage = tk.Button(frame, text="Parcourir",
                            command=lambda: jsonPath.set(askExcelPath()))
fileButtonStage.pack(side="right")


startButton = tk.Button(mainFrame, text="Générer", command=run)
startButton.pack(side="bottom")

currentMessage = tk.StringVar()
messageLabel = tk.Label(mainFrame, textvariable=currentMessage)
messageLabel.pack(side="bottom")


if __name__ == "__main__":
    root.mainloop()
