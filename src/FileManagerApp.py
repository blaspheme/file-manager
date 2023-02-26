from kivy.app import App
from kivy.uix.widget import Widget
from kivy.uix.label import Label
from kivy.uix.screenmanager import ScreenManager

from src.ui.ListScreen import ListScreen
from src.ui.EditScreen import EditScreen

class FileManagerApp(App):
    def build(self):
        # 创建 ScreenManager 并添加两个屏幕
        screen_manager = ScreenManager()
        screen_manager.add_widget(ListScreen(name="list_screen"))
        screen_manager.add_widget(EditScreen(name="edit_screen"))

        return screen_manager
