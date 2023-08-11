import 'package:flutter/material.dart';
import 'package:trackme/utilities/custom_callback_types.dart';
import 'package:flutter/services.dart';
import 'package:trackme/utilities/snackbar_factory.dart';

class TokenGenerator extends StatefulWidget {
  final GenerateToken generateToken;
  final String tokenType;

  const TokenGenerator({
    Key? key,
    required this.generateToken,
    required this.tokenType,
  }) : super(key: key);

  @override
  State<TokenGenerator> createState() => _TokenGeneratorState();
}

class _TokenGeneratorState extends State<TokenGenerator> {
  String _token = '-';
  bool _isGeneratingToken = false;

  Future<void> _generateNewToken() async {
    setState(() {
      _isGeneratingToken = true;
    });
    Map<String, dynamic> tokenResult = await widget.generateToken();
    if (tokenResult['code'] == 200) {
      setState(() {
        _isGeneratingToken = false;
        _token = tokenResult['detail']['token'];
      });
    }
  }

  Future<void> _onTokenTapped() async {
    await Clipboard.setData(ClipboardData(text: _token));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    SnackBar snackBar = SnackBarFactory.create(
      duration: 500,
      type: SnackBarType.success,
      content: 'Token Copied to Clipboard',
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${widget.tokenType} Token',
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 25,
          ),
        ),
        InkWell(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              _token,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 50,
              ),
            ),
          ),
          onTap: _token == '-' ? null : _onTokenTapped,
          borderRadius: BorderRadius.circular(12),
        ),
        ElevatedButton(
          onPressed: _isGeneratingToken ? null : _generateNewToken,
          child: _isGeneratingToken
              ? const SizedBox(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black45,
                  ),
                  height: 15,
                  width: 15,
                )
              : const Icon(Icons.refresh),
        ),
      ],
    );
  }
}
