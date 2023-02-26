from kivy.uix.screenmanager import Screen
from kivy.uix.button import Button

class EditScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        button = Button(text="Go back to first screen")
        button.bind(on_press=self.go_to_first_screen)
        self.add_widget(button)
    
    def go_to_first_screen(self, instance):
        # 获取 ScreenManager 并设置当前屏幕为第一个屏幕
        screen_manager = self.manager
        screen_manager.current = 'list_screen'
