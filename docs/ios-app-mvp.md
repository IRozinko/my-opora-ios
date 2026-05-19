# My Opora iOS — MVP

## Зачем приложение

Telegram-бот «Опора» уже работает как быстрый канал, но команды легко забывать. iOS-приложение должно стать основным интерфейсом системы:

- без запоминания команд;
- с быстрыми кнопками;
- с виджетами и уведомлениями;
- с будущей интеграцией в Calendar, Reminders, Shortcuts, Health;
- с едиными данными backend/Telegram/iOS.

## Главная идея

> Опора — личная система выхода из режима выживания.

Не таск-трекер. Не дневник. Не финприложение отдельно. А единая панель:

- деньги;
- семья;
- здоровье;
- работа;
- цели;
- восстановление.

## MVP экраны

### Сегодня

Главный экран дня:

- статус нервной системы;
- утренний ритуал;
- фокус дня;
- быстрый расход;
- текущие лимиты;
- семейный статус вечера;
- ближайшая цель.

### Финансы

- быстрый расход;
- быстрый доход;
- расходы сегодня / месяц;
- лимиты;
- кредитки;
- резерв;
- цели.

### Привычки

- утро;
- вечер;
- голос;
- образ;
- календарь привычек;
- статистика за 30 дней.

### Цели

- кредитки в ноль;
- резерв;
- новая машина;
- дом;
- Northbridge;
- семейные фонды.

### Настройки

- backend URL;
- Telegram link code;
- mock/API mode;
- уведомления;
- профиль.

## Backend API, который нужен

- `GET /api/today`
- `POST /api/expenses`
- `POST /api/income`
- `GET /api/finance/summary`
- `GET /api/finance/limits`
- `POST /api/nerve-status`
- `POST /api/habits/morning`
- `POST /api/habits/evening`
- `POST /api/habits/voice`
- `POST /api/habits/look`
- `GET /api/habits/stats`
- `GET /api/goals`
- `POST /api/goals`
- `POST /api/auth/link-code`
- `POST /api/auth/link-telegram`

## Авторизация MVP

1. iOS app генерирует link code.
2. В Telegram пользователь пишет `/link 123456`.
3. Backend связывает iOS device с Telegram user.
4. iOS получает token.

## Apple integrations later

### Notifications

- morning;
- nerve status;
- evening transition;
- evening review.

### Widgets

- quick expense;
- nerve status;
- focus of the day;
- family status.

### Shortcuts / Siri

- “Записать расход”;
- “Опора reset”;
- “Статус красный”;
- “Отметить утро”.

### Calendar / Reminders

- собеседования;
- Dou Days;
- follow-up;
- семейные события;
- задачи Northbridge.

### Health

- сон;
- пульс;
- тренировки;
- шаги;
- recovery mode на основе сна и нагрузки.

## MVP принцип

Сначала приложение должно снизить трение. Красоту докручиваем потом.

Главный критерий:

> Открыл приложение → за 5–10 секунд сделал нужное действие.
