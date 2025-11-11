# AI Chatbot Setup Guide

The chatbot now uses AI to provide intelligent responses about tasks, productivity, and analytics. This guide explains how to set it up.

## Features

- **ChatGPT-like conversations**: Natural language understanding and responses
- **Context-aware**: Uses your tasks, productivity data, and analytics to provide personalized answers
- **Task management**: Ask questions about your tasks, get suggestions, and productivity tips
- **Analytics insights**: Get explanations about your productivity data and trends
- **Productivity tips**: Receive personalized advice based on your data

## Setup Instructions

### Option 1: Using OpenAI API (Recommended)

1. **Get an OpenAI API Key**:
   - Go to https://platform.openai.com/api-keys
   - Sign up or log in
   - Create a new API key
   - Copy the key (starts with `sk-`)

2. **Configure the API Key**:
   - The API key can be set programmatically in the app
   - For production, use Firebase Functions or a backend server to securely store the key
   - You can also add it to the profile screen for user configuration

3. **Set the API Key in Code** (Temporary - for testing):
   ```dart
   import 'package:productivity_tracker_app/services/ai_config.dart';
   
   // In your app initialization
   await AIConfig.saveApiKey('your-api-key-here');
   ```

### Option 2: Using Free Alternatives

You can modify `lib/services/ai_service.dart` to use free AI APIs:

1. **Hugging Face Inference API**:
   - Sign up at https://huggingface.co/
   - Get an API token
   - Modify the `_callAIAPI` method to use Hugging Face endpoints

2. **Google Gemini API** (Free tier available):
   - Sign up at https://makersuite.google.com/app/apikey
   - Get an API key
   - Modify the service to use Gemini API

3. **Local LLM** (Advanced):
   - Use a local model with packages like `ollama_dart`
   - Run the model on the device or a local server

### Option 3: Use Fallback Mode (No API Key)

If no API key is set, the chatbot will use an intelligent fallback system that:
- Provides context-aware responses based on your data
- Answers common questions about tasks, productivity, and analytics
- Works offline without internet connection

## Usage

Once set up, the chatbot can answer questions like:

- **Task-related**: "How many tasks do I have?", "What tasks are pending?", "Suggest ways to prioritize my tasks"
- **Productivity**: "How productive am I?", "What's my completion rate?", "Give me productivity tips"
- **Analytics**: "Explain my analytics", "What does my completion rate mean?", "How can I improve?"
- **General**: "Hello", "Help me with productivity", "What can you do?"

## Security Notes

⚠️ **Important**: 
- Never commit API keys to version control
- For production apps, use Firebase Functions or a backend server to handle API calls
- Store API keys securely using environment variables or secure storage
- Consider implementing rate limiting to control API costs

## Cost Considerations

- OpenAI API charges per token used
- GPT-3.5-turbo is cost-effective for most use cases
- Monitor your usage at https://platform.openai.com/usage
- Set up usage limits in your OpenAI account

## Troubleshooting

1. **Chatbot not responding**: Check if API key is set correctly
2. **Generic responses**: API key might not be set, using fallback mode
3. **Errors in console**: Check API key validity and internet connection
4. **Slow responses**: API calls take time, this is normal

## Next Steps

1. Set up your API key using one of the methods above
2. Test the chatbot with various questions
3. Monitor API usage and costs
4. Consider implementing caching for common queries
5. Add more context about user's productivity patterns

