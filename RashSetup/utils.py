import urllib.request
import json
import typing
import pathlib


class JsonHandler:
    @staticmethod
    def fromLink(url: str):
        with urllib.request.urlopen(url) as raw:
            return raw.read().decode()

    @staticmethod
    def fromString(raw: str):
        return json.loads(raw)

    def __init__(self, file: typing.Union[pathlib.Path, str]):
        self._ = pathlib.Path(file)

    def load(self) -> dict:
        if not self._.exists():
            return {}

        return json.loads(self._.read_text())

    def dump(self, store: dict, **kwargs) -> int:
        return self._.write_text(json.dumps(store, indent=4, **kwargs))

    def close(self) -> None:
        self._.unlink(True)

    def __getitem__(self, key):
        raw = self.load()
        return raw, raw[key]

    def __setitem__(self, key, value):
        new = self.load()[key]
        new[key] = value
        self.dump(new)

    @property
    def file(self):
        return self._

    @file.setter
    def file(self, pth):
        self._ = pth
