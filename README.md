# vk-dump

Сохранение информации с vk (сообщения, стена...) на локальный диск в markdown, html и pdf (с некоторыми типами вложений)

## Сохраняются

1. Личные сообщения
    - разговоры один на один (без конференций)
    - пересылаемые сообщения (в т.ч. вложенные)
    - вложения

2. Стена (разных пользователей)
    - посты пользователя
    - посты, оставленные на его стене
    - комментарии
    - информация о количестве лайков и репостов

3. Аватарки
    - комментарии
    - лайки (поимённо, кто)

4. Вложения
    - репосты
    - фотки (скачать)
    - документы (скачать)
    - аудиозаписи (только название)


## Детали реализации

- Аккуратно escap-ить тело сообщений/постов в корректный markdown
- Всё, что касается output, вообще не должно генерировать никаких запросов!
- Возможно: выводить таблицей в markdown посты и другие сущности
- Комменты к аватаркам получаются не все, а только первые 100 (ну или сколько там укажешь в конфигурационном файле, но не более сотни. и, если честно, этого хватит). Ровно как и количество аватарок ограничено 1000 (да и у кого больше?)
- Пагинация: и сверху, и снизу
