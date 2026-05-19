# My Opora iOS

Нативное iOS-приложение для системы «Опора»: быстрые отметки, финансы, привычки, нервная система, цели и будущая интеграция с backend/Telegram-ботом.

## Цель

Сделать не ещё один таск-трекер, а личную панель управления:

- утренний и вечерний ритуалы;
- быстрый учёт расходов;
- статус нервной системы;
- семейные и финансовые цели;
- интеграция с backend `opora-whiskey-mode-bot`;
- дальнейшие интеграции с Apple Calendar, Reminders, Widgets, Shortcuts и Health.

## Текущий статус

MVP scaffold:

- SwiftUI app;
- главный экран «Сегодня»;
- финансы;
- привычки;
- цели;
- настройки API;
- локальный mock-режим;
- заготовка `OporaApiClient` для backend API.

## Генерация Xcode-проекта

Проект описан через XcodeGen.

```bash
brew install xcodegen
xcodegen generate
open MyOpora.xcodeproj
```

## План развития

1. MVP локально на iPhone.
2. REST API в backend.
3. Link Telegram user ↔ iOS app.
4. Push/local notifications.
5. Widgets.
6. Calendar / Reminders / Shortcuts.
7. Health integration: sleep, heart rate, workouts.

## Главная формула

> Опора — личная система выхода из режима выживания.
