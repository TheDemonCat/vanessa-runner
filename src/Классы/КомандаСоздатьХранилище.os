///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Создание хранилища 1С.
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

Перем Лог;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт

	ТекстОписания = 
		"     Создание хранилища 1С.
		|     ";

	ОписаниеКоманды = Парсер.ОписаниеКоманды(ПараметрыСистемы.ВозможныеКоманды().СоздатьХранилище, 
		ТекстОписания);
	
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "ПутьСоздаваемогоХранилища", "Строка подключения к хранилищу
	|	(возможно указание как файлового пути, так и пути через http или tcp)");
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "ЛогинАдминистратора", "Логин администратора хранилища 1С");
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "ПарольАдминистратора", "Пароль администратора хранилища 1С");

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

	ДанныеПодключения = ПараметрыКоманды["ДанныеПодключения"];
	СтрокаПодключения = ДанныеПодключения.СтрокаПодключения;
	Если Не ЗначениеЗаполнено(СтрокаПодключения) Тогда
		СтрокаПодключения = "/F";
	КонецЕсли;
	
	МенеджерКонфигуратора = Новый МенеджерКонфигуратора;

	МенеджерКонфигуратора.Инициализация(
		СтрокаПодключения, ДанныеПодключения.Пользователь, ДанныеПодключения.Пароль,
		ПараметрыКоманды["--v8version"], ПараметрыКоманды["--uccode"],
		ДанныеПодключения.КодЯзыка
		);

	Попытка
		МенеджерКонфигуратора.СоздатьХранилище(
			ПараметрыКоманды["ПутьСоздаваемогоХранилища"], ПараметрыКоманды["ЛогинАдминистратора"], 
			ПараметрыКоманды["ПарольАдминистратора"]);
	Исключение
		МенеджерКонфигуратора.Деструктор();
		ВызватьИсключение ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
	КонецПопытки;

	МенеджерКонфигуратора.Деструктор();

	Возврат МенеджерКомандПриложения.РезультатыКоманд().Успех;
КонецФункции // ВыполнитьКоманду
