from kivy.uix.screenmanager import Screen
from kivy.uix.button import Button

class ListScreen(Screen):
    def __init__(self, **kwargs):
        super(ListScreen, self).__init__(**kwargs)
        self.data = [{'text': str(x)} for x in range(100)]

    def go_to_second_screen(self):
        print('xxxxxxxxxxx')
        # 获取 ScreenManager 并设置当前屏幕为第二个屏幕
        screen_manager = self.manager
        screen_manager.current = 'edit_screen'
