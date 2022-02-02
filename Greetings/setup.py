from setuptools import setup, find_packages

setup(
    # meta data
    name="Greetings",
    version="0.1.0",
    description="Just Greets you in regular intervals",
    author="RahulARanger",
    author_email="saihanumarahul66@gmail.com",
    maintainer="RahulARanger",
    maintainer_email="saihanumarahul66@gmail.com",
    url="https://github.com/RahulARanger/RashSetup/Greetings",
    platforms=[
        "Operating System :: Microsoft :: Windows :: Windows 7",
        "Operating System :: Microsoft :: Windows :: Windows 8",
        "Operating System :: Microsoft :: Windows :: Windows 8.1",
        "Operating System :: Microsoft :: Windows :: Windows 10",
    ],
    classifiers=[
        "Development Status :: 3 - Alpha",
        "License :: OSI Approved :: MIT License",
        "Intended Audience :: Developers",
        "Programming Language :: Python :: 3.8",
    ],
    keywords="Plugin Manager, sample",

    # information
    packages=find_packages("."),
    include_package_data=True,
    entry_points={
        "console_scripts": "Greetings=Greetings.main:greet"
    }
)
