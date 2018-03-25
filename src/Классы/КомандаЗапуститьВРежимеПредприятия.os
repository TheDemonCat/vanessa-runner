///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Выполнение команды/действия в 1С:Предприятие в режиме тонкого/тонкого клиента с передачей запускаемых обработок и параметров
//
// TODO добавить фичи для проверки команды
// 
// Служебный модуль с набором методов работы с командами приложения
//
// Структура модуля реализована в соответствии с рекомендациями 
// oscript-app-template (C) EvilBeaver
//
///////////////////////////////////////////////////////////////////////////////////////////////////

#Использовать logos
#Использовать v8runner

Перем Лог;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

// Регистрация команды и ее аргументов/ключей
//
// Параметры:
//   ИмяКоманды - Строка - имя команды
//   Парсер - Парсер - объект парсера
//
Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт

	ТекстОписания = 
		"     Выполнение команды/действия в 1С:Предприятие в режиме тонкого/тонкого клиента с передачей запускаемых обработок и параметров
		|     ";

	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, 
		ТекстОписания);

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--uccode", "Ключ разрешения запуска");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--command", "Строка, передаваемая в ПараметрыЗапуска /C''");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--execute", 
		"Путь внешней обработки 1С для запуска в предприятии");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--additional", 
		"Дополнительные параметры для запуска предприятия.");
	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "--no-wait", 
		"Не ожидать завершения запущенной команды/действия");

	Парсер.ДобавитьКоманду(ОписаниеКоманды);
	
КонецПроцедуры // ЗарегистрироватьКоманду

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   ДополнительныеПараметры - Соответствие - дополнительные параметры (необязательно)
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач ДополнительныеПараметры = Неопределено) Экспорт

	Лог = ДополнительныеПараметры.Лог;

	// TODO отрефакторить получение ЗапускатьТолстыйКлиент
	ЗапускатьТолстыйКлиент = ОбщиеМетоды.УказанПараметрТолстыйКлиент(ПараметрыКоманды["--ordinaryapp"], Лог);
	ДанныеПодключения = ПараметрыКоманды["ДанныеПодключения"];
	
	МенеджерКонфигуратора = Новый МенеджерКонфигуратора;

	ПутьОбработки1С = ПараметрыКоманды["--execute"];
	ПутьОбработки1С = Заменить_runnerRoot_на_КаталогVanessaRunner(ПутьОбработки1С);
	ПутьОбработки1С = ОбщиеМетоды.ПолныйПуть(ПутьОбработки1С);
	
	ОжидатьЗавершения = Не ПараметрыКоманды["--no-wait"];

	МенеджерКонфигуратора.Инициализация(
		ДанныеПодключения.СтрокаПодключения, ДанныеПодключения.Пользователь, ДанныеПодключения.Пароль,
		ПараметрыКоманды["--v8version"], ПараметрыКоманды["--uccode"],
		ДанныеПодключения.КодЯзыка, ДанныеПодключения.КодЯзыкаСеанса
		);

	КомандаЗапуска = ПараметрыКоманды["--command"];
	Если НЕ ПараметрыСистемы.ЭтоWindows Тогда
		КомандаЗапуска = СтрЗаменить(КомандаЗапуска, """", "\""");
		КомандаЗапуска = СтрЗаменить(КомандаЗапуска, ";", "\;");
	Иначе
		КомандаЗапуска = """" + КомандаЗапуска + """";
	КонецЕсли;
	Попытка
		МенеджерКонфигуратора.ЗапуститьВРежимеПредприятия(
			КомандаЗапуска,
			ПутьОбработки1С,
			ЗапускатьТолстыйКлиент,
			ПараметрыКоманды["--additional"], ОжидатьЗавершения);
	
	Исключение
		МенеджерКонфигуратора.Деструктор();
		ВызватьИсключение ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
	КонецПопытки;

	МенеджерКонфигуратора.Деструктор();

	Возврат МенеджерКомандПриложения.РезультатыКоманд().Успех;
КонецФункции // ВыполнитьКоманду

Функция Заменить_runnerRoot_на_КаталогVanessaRunner(Знач ИсходнаяСтрока)
	Возврат СтрЗаменить(ИсходнаяСтрока, "$runnerRoot", ОбщиеМетоды.КаталогПроекта());
КонецФункции
