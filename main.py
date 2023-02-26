import kivy
from kivy.lang import Builder
from src.FileManagerApp import FileManagerApp

kivy.require('2.1.0')  # replace with your current kivy version !

# 加载指定KV文件
Builder.load_file('src/kv/listscreen.kv')

if __name__ == '__main__':
    FileManagerApp().run()
