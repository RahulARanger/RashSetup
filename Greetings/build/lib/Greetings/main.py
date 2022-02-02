import click
import webbrowser


@click.command("Greetings")
def run():
    """
    Greetings
    """
    webbrowser.open("https://www.google.com")


if __name__ == "__main__":
    run()
