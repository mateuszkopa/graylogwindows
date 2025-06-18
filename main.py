print("IP graylog:")
ip = input()
name_koncowka = "koncowki.py"
f = open(name_koncowka, "x")
py_koncowka = """import os
import requests
import zipfile
import subprocess
import shutil
import elevate

def download_file(url, destination):
    try:
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        with open(destination, "wb") as f:
            f.write(response.content)
    except requests.RequestException as e:
        print(f"Błąd podczas pobierania {url}: {e}")
        exit(1)

def extract_zip(zip_path, extract_to):
    try:
        with zipfile.ZipFile(zip_path, "r") as zip_ref:
            zip_ref.extractall(extract_to)
    except zipfile.BadZipFile as e:
        print(f"Błąd podczas rozpakowywania {zip_path}: {e}")
        exit(1)

def ensure_directory_exists(path):
    os.makedirs(path, exist_ok=True)

def main():
    sysmon_url = "https://download.sysinternals.com/files/Sysmon.zip"
    config_url = "https://raw.githubusercontent.com/olafhartong/sysmon-modular/master/sysmonconfig.xml"
    nxlog_conf_url = "http://""" + ip + """/koncowki/nxlog.conf"
    nxlog_conf_destination = r"C:\\Program Files\\nxlog\\conf\\nxlog.conf"
    if os.path.exists(nxlog_conf_destination):
        os.remove(nxlog_conf_destination)
    download_file(nxlog_conf_url, nxlog_conf_destination)

    temp_dir = os.path.dirname(os.path.abspath(__file__))
    zip_file = os.path.join(temp_dir, "Sysmon.zip")
    destination = os.path.join(temp_dir, "Sysmon")
    config_file = os.path.join(destination, "sysmonconfig.xml")

    download_file(sysmon_url, zip_file)
    extract_zip(zip_file, destination)
    download_file(config_url, config_file)

    try:
        subprocess.run([
            os.path.join(destination, "Sysmon.exe"), "-accepteula", "-i", config_file
        ], check=True, shell=True)
    except subprocess.CalledProcessError as e:
        print(f"Błąd podczas uruchamiania Sysmon: {e}")

    try:
        os.remove(zip_file)
        shutil.rmtree(destination)
    except OSError as e:
        print(f"Błąd podczas czyszczenia plików tymczasowych: {e}")

if __name__ == "__main__":
    elevate.elevate()
    main()
"""
with open(name_koncowka, "a") as f:
    f.write(py_koncowka)
    f.close()

name_serwer = "serwery.py"
f = open(name_serwer, "x")
py_serwer = """import os
import requests
import zipfile
import subprocess
import shutil
import elevate

def download_file(url, destination):
    try:
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        with open(destination, "wb") as f:
            f.write(response.content)
    except requests.RequestException as e:
        print(f"Błąd podczas pobierania {url}: {e}")
        exit(1)

def extract_zip(zip_path, extract_to):
    try:
        with zipfile.ZipFile(zip_path, "r") as zip_ref:
            zip_ref.extractall(extract_to)
    except zipfile.BadZipFile as e:
        print(f"Błąd podczas rozpakowywania {zip_path}: {e}")
        exit(1)

def ensure_directory_exists(path):
    os.makedirs(path, exist_ok=True)

def main():
    sysmon_url = "https://download.sysinternals.com/files/Sysmon.zip"
    config_url = "https://raw.githubusercontent.com/olafhartong/sysmon-modular/master/sysmonconfig.xml"
    nxlog_conf_url = "http://""" + ip + """/serwery/nxlog.conf"
    nxlog_conf_destination = r"C:\\Program Files\\nxlog\\conf\\nxlog.conf"
    if os.path.exists(nxlog_conf_destination):
        os.remove(nxlog_conf_destination)
    download_file(nxlog_conf_url, nxlog_conf_destination)

    temp_dir = os.path.dirname(os.path.abspath(__file__))
    zip_file = os.path.join(temp_dir, "Sysmon.zip")
    destination = os.path.join(temp_dir, "Sysmon")
    config_file = os.path.join(destination, "sysmonconfig.xml")

    download_file(sysmon_url, zip_file)
    extract_zip(zip_file, destination)
    download_file(config_url, config_file)

    try:
        subprocess.run([
            os.path.join(destination, "Sysmon.exe"), "-accepteula", "-i", config_file
        ], check=True, shell=True)
    except subprocess.CalledProcessError as e:
        print(f"Błąd podczas uruchamiania Sysmon: {e}")

    try:
        os.remove(zip_file)
        shutil.rmtree(destination)
    except OSError as e:
        print(f"Błąd podczas czyszczenia plików tymczasowych: {e}")

if __name__ == "__main__":
    elevate.elevate()
    main()
"""
with open(name_serwer, "a") as f:
    f.write(py_serwer)
    f.close()

