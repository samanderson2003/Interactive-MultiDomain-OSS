# RAN AI Chatbot Setup Guide

## Overview
The RAN Bot is an AI-powered assistant that helps users with Radio Access Network queries, BTS management, network performance, and troubleshooting.

## Features
- 🤖 **AI-Powered**: Uses OpenAI GPT-4o-mini for intelligent responses
- 📡 **RAN Expert**: Specialized knowledge in telecommunications and network infrastructure
- 💬 **Interactive Chat**: Real-time conversation with typing indicators
- ⚡ **Quick Questions**: Pre-configured common RAN queries
- 🎨 **Beautiful UI**: Animated Lottie bot with modern design

## Setup Instructions

### 1. Get OpenAI API Key
1. Visit [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
2. Sign in or create an account
3. Click "Create new secret key"
4. Copy your API key (starts with `sk-`)
5. Keep it secure - never share it publicly

### 2. Configure in App
1. Click the floating "Ask RAN Bot" button on the RAN Dashboard
2. Enter your OpenAI API key when prompted
3. Click "Start Chat"
4. Begin asking questions!

### 3. Using the Bot

#### Sample Questions:
- "What is RSRP and how is it measured?"
- "How to troubleshoot high capacity utilization?"
- "Explain BTS signal metrics"
- "What causes critical alerts?"
- "How to optimize network performance?"
- "Difference between 4G and 5G RAN?"

#### Features:
- **Quick Questions**: Tap pre-defined questions for instant queries
- **Clear Chat**: Reset conversation anytime
- **Settings**: Update API key if needed
- **Typing Indicator**: See when bot is processing your query

## Bot Knowledge Base

The RAN Bot specializes in:

### 1. BTS Management
- Signal metrics (RSRP, RSRQ, SINR, CQI)
- Capacity utilization and optimization
- Hardware configurations
- Network performance monitoring

### 2. Network Infrastructure
- 4G LTE and 5G NR technologies
- Cell tower deployment
- Frequency bands and spectrum
- Handover procedures

### 3. Performance Metrics
- Key Performance Indicators (KPIs)
- Signal strength interpretation
- Throughput and latency
- Network capacity planning

### 4. Alert Management
- Critical, Major, Minor alerts
- Threshold configurations
- Root cause analysis
- Preventive maintenance

### 5. Technical Operations
- Network optimization
- Interference mitigation
- Load balancing
- Disaster recovery

## Technical Details

### Technologies Used
- **AI Model**: GPT-4o-mini (OpenAI)
- **Animation**: Lottie (loading bot.json)
- **State Management**: Provider
- **UI Framework**: Flutter Material Design

### Files Structure
```
lib/RAN/
├── model/
│   └── ran_bot_model.dart          # Chat message and knowledge base models
├── controller/
│   └── ran_bot_contoller.dart      # OpenAI integration and state management
└── view/
    └── ran_bot_view.dart            # Chat UI with Lottie animation
```

### API Usage
- Model: `gpt-4o-mini` (cost-effective, fast responses)
- Temperature: 0.7 (balanced creativity/accuracy)
- Max Tokens: 800 (comprehensive answers)
- Context: Last 10 messages retained

## Cost Estimation

OpenAI pricing (as of 2025):
- GPT-4o-mini: ~$0.15 per 1M input tokens, ~$0.60 per 1M output tokens
- Average query: ~$0.001-0.003 per conversation

## Troubleshooting

### "Bot not initialized"
- Ensure you entered a valid OpenAI API key
- Check API key starts with `sk-`
- Try re-entering the key in Settings

### "Failed to get response"
- Check internet connection
- Verify API key is active
- Ensure OpenAI account has credits
- Try simpler queries

### Slow responses
- Normal for complex questions (5-15 seconds)
- GPT-4o-mini is optimized for speed
- Network latency may affect response time

## Security Notes

⚠️ **Important**:
- Never commit API keys to version control
- Store keys securely (environment variables in production)
- Monitor API usage to prevent abuse
- Consider implementing rate limiting for production

## Future Enhancements

Possible improvements:
- [ ] Local storage of API key (encrypted)
- [ ] Voice input/output
- [ ] RAG (Retrieval Augmented Generation) with actual BTS data
- [ ] Multi-language support
- [ ] Conversation export
- [ ] Analytics on common queries

## Support

For issues or questions:
- Check OpenAI documentation: [platform.openai.com/docs](https://platform.openai.com/docs)
- Review error messages in chat
- Clear chat and try again
- Restart app if persistent issues

---

**Enjoy chatting with RAN Bot! 🤖📡**
