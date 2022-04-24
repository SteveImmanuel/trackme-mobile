import 'package:flutter/material.dart';
import 'package:trackme/utilities/custom_callback_types.dart';

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
        Text(
          _token,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 50,
          ),
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
