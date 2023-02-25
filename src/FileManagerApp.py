from kivy.app import App
from kivy.uix.widget import Widget


class PongGame(Widget):
    pass


class FileManagerApp(App):
    def build(self):
        return PongGame()
