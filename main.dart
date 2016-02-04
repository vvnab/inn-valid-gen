library inn_valid_gen;

import 'package:args/args.dart';
import 'dart:math' as math;

int _mult(inn, mult) {
	var result = [];
	mult.asMap().forEach((k, i) {
		result.add(i * int.parse(inn[k]));
	});
	return result.reduce((s, i) => s + i);
}

int _n10(inn) {
	// юр.лицо
	// Для 10-значного ИНН, присваиваемого юридическому лицу, контрольной является последняя, десятая цифра:
	// {n_{10} = ((2n_1 + 4n_2 + 10n_3 + 3n_4 + 5n_5 + 9n_6 + 4n_7 + 6n_8 + 8n_9) mod 11) mod 10}
	var mult = [2, 4, 10, 3, 5, 9, 4, 6, 8];
	return (_mult(inn, mult) % 11) % 10;
}

int _n11(inn) {
	// физ.лицо
	// Для 12-значного ИНН, присваиваемого физическому лицу, контрольными являются последние две цифры:
	// n_{11} = ((7n_1 + 2n_2 + 4n_3 + 10n_4 + 3n_5 + 5n_6 + 9n_7 + 4n_8 + 6n_9 + 8n_{10}) mod 11) mod 10
	var mult = [7, 2, 4, 10, 3, 5, 9, 4, 6, 8];
	return (_mult(inn, mult) % 11) % 10;
}

int _n12(inn) {
	// физ.лицо
	// Для 12-значного ИНН, присваиваемого физическому лицу, контрольными являются последние две цифры:
	// n_{12} = ((3n_1 + 7n_2 + 2n_3 + 4n_4 + 10n_5 + 3n_6 + 5n_7 + 9n_8 + 4n_9 + 6n_{10} + 8n_{11}) mod 11) mod 10
	var mult = [3, 7, 2, 4, 10, 3, 5, 9, 4, 6, 8];
	return (_mult(inn, mult) % 11) % 10;
}

List<dynamic> validate(String inn) {
	// Возвращает [bool flag, String details]
	if (inn.length == 10) {
		var result = inn[9] == '${_n10(inn)}';
		return [result, result ? 'ok' : 'last number: ${_n10(inn)}'];
	} else if (inn.length == 12) {
		var result = inn[10] == '${_n11(inn)}' && inn[11] == '${_n12(inn)}';
		return [result, result ? 'ok' : 'last numbers: ${_n11(inn)}, ${_n12(inn)}'];
	} else {
		return [false, 'incorrect number quantity (must be 10 or 12)'];
	}
}

String generate(String type) {
	var random = new math.Random();
	var rawString = random.nextDouble().toString().substring(2);
	if (type == '10') {
		// номер для юр.лица
		var inn = rawString.substring(0, 9);
		inn += _n10(inn).toString();
		return inn;
	} else {
		// номер для физ.лица
		var inn = rawString.substring(0, 10);
		inn += _n11(inn).toString();
		inn += _n12(inn).toString();
		return inn;
	}
}

void main(List<String> args) {
	var parser = new ArgParser();

	parser
		..addOption('mode', defaultsTo: 'valid', allowed: ['valid', 'gen'])
		..addOption('type', defaultsTo: '10');

	var arguments = parser.parse(args);

	if (arguments['mode'] == 'gen') {
		var inn = generate(arguments['type']);
		print('INN: $inn');
	} else {
		var inn = arguments.rest[0];
		var valid = validate(inn);
		print('${valid[0] ? "" : "Incorrect INN!\n"}${valid[1]}');
	}
}
