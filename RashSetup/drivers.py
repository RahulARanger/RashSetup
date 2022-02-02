import pathlib
import shutil
import subprocess
from selenium import webdriver
from webdriver_manager.firefox import GeckoDriverManager
from selenium.webdriver.firefox.firefox_binary import FirefoxBinary
from selenium.webdriver.firefox.firefox_profile import FirefoxProfile
from selenium.webdriver.firefox.options import Options
import webbrowser
import typing


# WARNING: DON'T USE DEFAULT VALUES FOR THIS BELOW FUNCTIONS
# AS THEY TRY TO SAVE CACHE FILES IN SITE PACKAGES
# AND THEY WON'T BE RECONGIZED WHILE UNINSTALLING

def check_for_fox() -> str:
    path = FirefoxBinary()._start_cmd
    ... if path else webbrowser.open("https://www.mozilla.org/en-US/firefox/")
    assert path, "Unable to find 🔥 + 🦊 browser, Please install it 😊"

    return path


def _run_fox(*args) -> subprocess.CompletedProcess:
    binary = check_for_fox()
    return subprocess.run([
        binary, *args
    ], check=True)


def init(name="RashDrivers", drivers_path=__file__) -> typing.Tuple[pathlib.Path, pathlib.Path, subprocess.CompletedProcess]:
    """

    :return:
    """
    drivers_path = pathlib.Path(drivers_path)
    drivers_path = drivers_path if drivers_path.is_dir() else drivers_path.parent
    drivers_path /= "Drivers"
    profile_path = drivers_path / "Profiles"

    profile_path.mkdir(parents=True, exist_ok=True)

    return drivers_path, profile_path, _run_fox("--profileManager", "--CreateProfile", f"{name} {profile_path}")


def clear_cache(drivers_path=pathlib.Path(__file__).parent / "Drivers") -> typing.NoReturn:
    shutil.rmtree(drivers_path)


def download_driver(drivers_path=pathlib.Path(__file__).parent / "Drivers") -> str:
    """
    Using webdriver_manager, it auto downloads the latest version of the 🦊 driver
    :return: Path for the Driver
    """
    return GeckoDriverManager(path=drivers_path).install()


def is_there(profile_path=pathlib.Path(__file__).parent / "Drivers" / "Profiles") -> bool:
    """
    Checks if the profile is created or not
    :return: True if the profile is created, False otherwise
    """
    return (profile_path / "parent.lock").exists()  # I feel, this file exists for , that is if we had created profile


def play_and_save(profile_name="RashDrivers") -> subprocess.CompletedProcess:
    return _run_fox("-P", profile_name)


def manager() -> subprocess.CompletedProcess:
    return _run_fox("--profileManager")


def set_preferences(profile_path=pathlib.Path(__file__).parent / "Drivers" / "Profiles") -> FirefoxProfile:
    profile = FirefoxProfile(profile_path)
    return profile


def get_driver(drivers_path=pathlib.Path(__file__).parent / "Drivers") -> webdriver.Firefox:
    drivers_path = pathlib.Path(drivers_path)
    return webdriver.Firefox(set_preferences(drivers_path / "Profiles"), executable_path=download_driver(drivers_path))


def bye(drivers_path):
    """
    Make sure to run this before uninstallation, else cache won't be cleared
    :return:
    """
    manager()
    clear_cache(drivers_path)


if __name__ == "__main__":
    drivers, _profile, _ = init()
    play_and_save()
    clear_cache()
