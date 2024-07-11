import 'package:flutter/material.dart';
import 'package:tourist_guide/text_converter/Translator_Const.dart';
import 'package:translator/translator.dart';

class TranslationScreen extends StatefulWidget {
  final String inputText;

  TranslationScreen({required this.inputText});

  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final GoogleTranslator _translator = GoogleTranslator();
  String _translatedText = 'Translation will appear here';
  String _detectedLanguage = '';
  String _selectedLanguage = 'en';


  @override
  void initState() {
    super.initState();
    _translateText();
  }

  void _translateText() async {
    if (widget.inputText.isNotEmpty) {
      var translation = await _translator.translate(widget.inputText, to: 'en');
      setState(() {
        _translatedText = translation.text;
        _detectedLanguage = translation.sourceLanguage.name;
      });
    }
  }

  void _translateToSelectedLanguage() async {
    if (widget.inputText.isNotEmpty) {
      var translation = await _translator.translate(widget.inputText, to: _selectedLanguage);
      setState(() {
        _translatedText = translation.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Translation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Input Text:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              widget.inputText,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Detected Language: $_detectedLanguage',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 20),
            Text(
              'Translation:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              _translatedText,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Translate to:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedLanguage,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                });
                _translateToSelectedLanguage();
              },
              items: TranslatorConst.languages.map<DropdownMenuItem<String>>((Map<String, String> language) {
                return DropdownMenuItem<String>(
                  value: language['code'],
                  child: Text(language['name']!),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
