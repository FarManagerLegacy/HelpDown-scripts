## HelpDown Makefile scripts

Предлагается [система сборки документации](https://github.com/FarManagerLegacy/HelpDown-scripts)
в различных форматах (**.hlf**, **.html**, и **.md** для форума)
из единого источника на базе Markdown.

Система представляет собой базовый `Makefile`, и несколько lua-скриптов (“фильтров”),
необходимых для тонкой настройки вывода.

Предполагается использовать это наподобие конструктора: для каждого проекта создаётся свой локальный `Makefile`,
в котором подключается базовый, и указываются необходимые фильтры (имеющиеся в наборе, либо добавленные локально).

Требования:

- [pandoc](https://pandoc.org/installing.html)
- [HtmlToFarHelp](https://www.nuget.org/packages/HtmlToFarHelp) (или прямая ссылка на [файл пакета](https://www.nuget.org/api/v2/package/HtmlToFarHelp/))
- [make](https://sourceforge.net/projects/ezwinports/files/) или `winget install ezwinports.make`
- `Makefile` + cкрипты из данного репозитория. Или [архив](https://github.com/FarManagerLegacy/HelpDown-scripts/zipball/master).

Для чего же нужны фильтры, приведу лишь несколько примеров:

- Для презентации какого-либо скрипта на форуме его документацию стоит специально подготовить, в частности:
  <details>

  - Поместить все разделы кроме первого в спойлеры, чтобы сэкономить место в посте.
  - Исправить форматирование при наличии одиночного `*`, поскольку стандартный способ экранирования слешем на форуме не работает.
  - *DefinitionList* ([Description List](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/dl)) не является стандартной фичей маркдауна, его надо заменить на *BulletList*.
  - Преобразование ссылок:
    - Движок форума не создаёт внутренние ссылки, поэтому их надо убрать (заменить на просто жирный текст).
    - Ссылки на справку фара работают только в **hlf**. А в **html** и *для форума* их надо заменять на что-то более полезное.
    - Аналогично со ссылками на локальные **\*.chm** и пр.
    - При конвертации в Github-flavored Markdown у заголовков пропадают id, указанные посредством attribute syntax,
      а значит ломаются ссылки. Их можно исправить, используя “автоматические идентификаторы” (Implicit Headers IDs).

  </details>

  Никто в здравом уме не станет сам с этим возиться, но если всё автоматически, то почему бы и нет.
- Для **html** полезно Title не оставлять пустой, а продублировать туда первый Header.
- Для **hlf**:
  - Cформировать индекс справки, и в каждый раздел добавить перекрёстные ссылки на другие
    (например в верхнем блоке как в справке [LuaCheck](https://forum.farmanager.com/viewtopic.php?f=15&t=9650). Или в нижнем, как в [BufferScroll](https://forum.farmanager.com/viewtopic.php?t=8675)).
  - Выделить внутренние заголовки, добавив их содержимому дополнительный отступ.

Чтобы подключить всё это к своему проекту достаточно `Makefile` подобного примеру в `Makefile.sample`.  
Всё, теперь при наличии исходного документа в файле с расширением **\*.text** достаточно запустить команду `make` для создания **\*.hlf**.  
Или же явно указать цель: `make hlf`, `make html`, `make forum`.  
В качестве цели также может быть указано имя результирующего файла.
