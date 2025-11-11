import 'package:flutter/material.dart';
import '../../services/quote_service.dart';

class QuoteWidget extends StatefulWidget {
  final QuoteService quoteService;
  final Color themeColor;
  final bool isDark;

  const QuoteWidget({
    Key? key,
    required this.quoteService,
    required this.themeColor,
    this.isDark = false,
  }) : super(key: key);

  @override
  State<QuoteWidget> createState() => _QuoteWidgetState();
}

class _QuoteWidgetState extends State<QuoteWidget> {
  String? _quote;
  String? _author;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  Future<void> _fetchQuote() async {
    setState(() => _isLoading = true);
    try {
      final data = await widget.quoteService.fetchQuote();
      setState(() {
        _quote = data['content'];
        _author = data['author'];
      });
    } catch (e) {
      setState(() {
        _quote = "Failed to load quote. Try again later.";
        _author = null;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.isDark ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: widget.themeColor.withOpacity(0.3)),
      ),
      elevation: 5,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  Text(
                    _quote ?? "Loading quote...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.isDark ? Colors.white70 : Colors.black87,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_author != null && _author!.isNotEmpty)
                    Text(
                      "- $_author",
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.isDark
                            ? Colors.grey[400]
                            : Colors.black54,
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _fetchQuote,
              icon: const Icon(Icons.refresh),
              label: const Text("New Quote"),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.themeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
