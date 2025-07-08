# План на 8 дней
P. s. обращение к замечательным фронтендерам. Я вставляла вам куски кода. Я писала их по памяти на силе духа, без чата гпт, просто как что ориентировочно должно выглядеть. Этому не стоит верить на слово

## 1 день - база 

## Бекенд (артур)

- [ ] Подготовить базовые модели (User в user-service и StressSession в stress-tracker service)
- [ ] Настроить подключение к постгре (все можно посмотреть в docker-compose.yaml)
- [ ] Создать миграцию пользователей в user-service
- [ ] Создать миграцию сессий в stress-tracker-service

## Катя

- [ ] Сделать экран регистрации (в lib/screens/registration_screen.dart)
(то есть ник, имеил, пароль, повторение пароля)
- [ ] Сделать ограничение, что пароль должен иметь от 5 символов и хотя бы одну букву, проверка пустых полей, вывод ошибки в противном случае
- [ ] Подключить его в main.dart 
- [ ] Сразу все сделать максимально по красоте, так как задача сама по себе не супер сложная

## Ксюша

- [ ] Сделать экран логина (lib/screens/login_screen.dart)
(почта и пароль)
- [ ] Проверка пустых полей, вывод ошибки в противном случае
- [ ] Подключить в main.dart
- [ ] Сразу все сделать максимально по красоте, так как задача сама по себе не супер сложная

# Катарина

- [ ] Сделать экран Главной страницы после входа (lib/screens/home_screen.dart)
пока что просто добро пожаловать и красивые цвета
- [ ] Подключить в main.dart (конечно же по пути /)

## Ира (кто-то)

- [ ] Хз просто подниму докер несчастный
- [ ] Составить план на оставшиеся дни

## 2 день - аутентификация

### Бекенд (артур)

- [ ] Регистрация POST /register
- Принимает ник, email, пароль
- Хеширует пароль (bcrypt)
- Создаёт запись в users

- [ ] Логин POST /login
- Принимает email, пароль
- При успехе генерирует JWT

- [ ] Использовать "github.com/golang-jwt/jwt/v5"
- [ ] Где что хранить думаю сам знаешь

### Ира 

- [ ] Написать dockerfile для обоих сервисов
- [ ] Расписать остальную хуйню в документации хз
- [ ] Все-таки прописать всевозможные эндпоинты которые в итоге должны быть

### Катя

- [ ] Интеграция экрана регистарции с Api (!!!)
- Создать AuthService (lib/services/auth_service.dart)
- Метод регистрации если что:
```
Future<void> register(String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/register'),
    body: json.encode({'email': email, 'password': password}),
    headers: {'Content-Type': 'application/json'},
  );
  if (response.statusCode != 201) {
    throw Exception('Ошибка регистрации');
  }
}
```
- Подключить вызов к кнопке регистрации

### Ксюша

- [ ] Интеграция логина 
- [ ] В AuthService (путь указан выше) метод логина:
```
Future<String> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/login'),
    body: json.encode({'email': email, 'password': password}),
    headers: {'Content-Type': 'application/json'},
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['token'];
  }
  throw Exception('Ошибка входа');
}
```
- [ ] Сохранение jwt в SecureStorage

### Катарина

- [ ] Связать экран главной страницы со входом
- [ ] Создать SplashScreen для проверки токена
(Это первый экран, который показывается сразу при запуске приложения.
Он нужен для проверки, сохранён ли токен авторизации (jwt). 
решения, куда переходить:

- если токен есть и валиден, показываем главную страницу,

- если токена нет, показываем экран входа.

так пользователь не видит моргание логина, если он авторизован.)

- [ ] При старте Flutter-приложения загрузиться первым экраном.
- [ ] Проверить, сохранён ли токен в SecureStorage.
- [ ] Если токен есть — попытаться сделать запрос (например, GET /sessions) и убедиться, что токен валиден.


## 3 день - круд стресс сессий 

### Бекенд 

- [ ] Создание стресс сессий POST /sessions
{
  "description": "Переживал на работе",
  "stress_level": 7,
  "date": "2025-07-09"
}
- Из JWT вытаскивать user_id

- Записывать в таблицу sessions

- [ ] Список всех сессий пользователя GET /sessions
[
  {
    "id": "...",
    "description": "...",
    "stress_level": 7,
    "date": "2025-07-09",
    "created_at": "..."
  }
]

- [ ] Удаление сессий /sessions/{id}

### Катя
- [ ] Сделать экран добавления сессии (add_session_screen.dart)
- Описание
- Уровень стресса (слайдер от 1 до 10)
- Дата 
- Кнопка "Сохранить"
```
Future<void> addSession(String token, String description, int level, DateTime date) async {
  final response = await http.post(
    Uri.parse('$baseUrl/sessions'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    },
    body: json.encode({
      'description': description,
      'stress_level': level,
      'date': date.toIso8601String()
    }),
  );
  if (response.statusCode != 201) throw Exception('Ошибка создания');
}
```
- [ ] После кнопки сохранить перенос на домашнюю страницу со всплывающим уведомлением "успешно сохранено"

### Ксюша

- [ ] Создание экрана списка сессий (sessions_list_screen.dart)
- 
```Future<List<Session>> getSessions(String token) async {
  final response = await http.get(
    Uri.parse('$baseUrl/sessions'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (response.statusCode == 200) {
    final List data = json.decode(response.body);
    return data.map((e) => Session.fromJson(e)).toList();
  }
  throw Exception('Ошибка загрузки');
}
```
- Модель Session
```
class Session {
  final String id;
  final String description;
  final int stressLevel;
  final DateTime date;

  Session({required this.id, required this.description, required this.stressLevel, required this.date});

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    id: json['id'],
    description: json['description'],
    stressLevel: json['stress_level'],
    date: DateTime.parse(json['date']),
  );
}
```
- [ ] Отображать ListView (виджет для отображения списка элементов на экране, чето вроде ленты. я в душе не ебу как оно делается так что кода не будет)

### Катарина
- [ ] Наконец-то избавляемся от затычки экрана
-  Добавить Navigator.push после логина и регистрации
- [ ] Создать Drawer или BottomNavigationBar:
(Главная страница, добавить сессию, история сессий)
- [ ] при логине сразу загружать список сессий (Когда пользователь успешно вошёл в систему (то есть логин прошёл, сервер вернул JWT), приложение сразу делает запрос к серверу, чтобы получить его стресс-сессии и показать их на экране.)
НУ ИЛИ 
1. Пользователь ввёл email и пароль → нажал кнопку Войти
2. Сервер вернул токен (JWT)
3. Сохраняется токен в SecureStorage
4. Мгновенно делает запрос GET /sessions
5. Загружает все его записи стресса
6. Показывает их в списке на главной странице
после входа: ```
final token = await authService.login(email, password);
await storage.write(key: 'jwt_token', value: token); ```
 
передача списка:
```
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => SessionsListScreen(sessions: sessions),
  ),
);
```
### Ира 

- [ ] Добавить CORS чтобы все работало 


## День 4 - статистика и рекомендации

### Артур 
- [ ] Эндпоинты статистики и рекомендаций 
- GET /stats
```
{
  "total_sessions": 5,
  "average_stress": 6.3
}
```
- GET /recommendations
```
[
  {"id":1, "title":"Дыхательные упражнения", "text":"..."},
  {"id":2, "title":"Прогулка", "text":"..."}
]
```

### Ира 

- [ ] Наполнить таблицу recommendations 
- [ ] Сделать тестовые данные для всего остального


### Катя

- [ ] Сделать экран рекомендаций recommendations_screen.dart
- Подгрузка рекомендаций из api
- Отображать ListView (заголовок, текст) (выше объясняла)

### Ксюша

- [ ] Сделать экран статистики stats_screen.dart
- Подгружать /stats 
- [ ] Красиво выводить что-то вроде:
Всего сессий: 5
Средний уровень стресса: 6.3
- и в зависимости от кровня стресса выводить всякие поддерживающие надписи
- [ ] по желанию и возможностям ебануть график

### Катарина

- [ ] Доработать навигацию (если надо)
- [ ] В меню добавить пункты "Статистика" и "Рекомендации"



