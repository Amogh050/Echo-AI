import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:echo_ai/feature_box.dart';
import 'package:echo_ai/gemini_services.dart';
import 'package:echo_ai/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  final GeminiServices geminiServices = GeminiServices();
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;
  bool isLoading = false;
  String loadingMessage = 'Thinking...';

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    
    // Set completion handler to release resources when speaking is done
    flutterTts.setCompletionHandler(() {
      // This is called when TTS finishes speaking
      print('TTS completed');
    });
    
    // Set error handler
    flutterTts.setErrorHandler((error) {
      print('TTS error: $error');
    });
    
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }
  
  // Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // When app is paused or inactive, stop TTS
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive || 
        state == AppLifecycleState.detached) {
      flutterTts.stop();
    }
  }

  @override
  void dispose() {
    // Stop speech recognition
    speechToText.stop();
    
    // Release TTS resources
    flutterTts.stop();
    
    // Additional shutdown/cleanup for TTS
    flutterTts.pause();
    
    // On platforms that support it, completely shutdown TTS engine
    try {
      flutterTts.awaitSpeakCompletion(false);
    } catch (e) {
      print('Error during TTS shutdown: $e');
    }
    
    // Remove observer
    WidgetsBinding.instance.removeObserver(this);
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
          child: const Text(
            'Echo AI',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // leading: Icon(
        //   Icons.menu,
        //   color: Pallete.accentBlue,
        // ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.lightbulb_outline,
              color: Pallete.accentBlue,
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Pallete.darkBackground,
              Pallete.darkSurfaceColor,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // virtual assistant picture
              SizedBox(height: 10,),
              ZoomIn(
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        height: 120,
                        width: 120,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: Pallete.assistantCircleColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Pallete.accentBlue.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 123,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/virtualAssistant.png'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // chat bubble
              FadeInRight(
                child: Visibility(
                  visible: generatedImageUrl == null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 40,
                    ).copyWith(top: 30),
                    decoration: BoxDecoration(
                      color: Pallete.darkSurfaceColor,
                      border: Border.all(color: Pallete.borderColor),
                      borderRadius: BorderRadius.circular(20).copyWith(topLeft: Radius.zero),
                      boxShadow: [
                        BoxShadow(
                          color: Pallete.accentBlue.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: isLoading
                          ? _buildLoadingIndicator()
                          : generatedContent == null
                              ? Text(
                                  'Hi there, how can I assist you today?',
                                  style: TextStyle(
                                    fontFamily: 'Cera Pro',
                                    color: Pallete.mainFontColor,
                                    fontSize: 22,
                                  ),
                                )
                              : SelectableText(
                                  generatedContent!,
                                  style: TextStyle(
                                    fontFamily: 'Cera Pro',
                                    color: Pallete.mainFontColor,
                                    fontSize: 18,
                                    height: 1.4, // Add line height for better readability
                                  ),
                                ),
                    ),
                  ),
                ),
              ),
              if (generatedImageUrl != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Pallete.accentBlue.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: isLoading
                        ? _buildLoadingIndicator(isImage: true)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: generatedImageUrl == null
                                ? const Text('Problem occurred while generating the image')
                                : Image.network(generatedImageUrl!),
                          ),
                  ),
                ),
              SlideInLeft(
                child: Visibility(
                  visible: generatedContent == null && generatedImageUrl == null,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(top: 10, left: 22),
                    child: const Text(
                      'What can I help you with?',
                      style: TextStyle(
                        fontFamily: 'Cera Pro',
                        color: Pallete.mainFontColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              // features list
              Visibility(
                visible: generatedContent == null && generatedImageUrl == null,
                child: Column(
                  children: [
                    SlideInLeft(
                      delay: Duration(milliseconds: start),
                      child: FeatureBox(
                        color: Pallete.firstSuggestionBoxColor,
                        headerText: 'Gemini',
                        description:
                            'A smarter way to stay organized and informed with Gemini',
                      ),
                    ),
                    SlideInLeft(
                      delay: Duration(milliseconds: start + delay),
                      child: FeatureBox(
                        color: Pallete.secondSuggestionBoxColor,
                        headerText: 'Stability Diffusion',
                        description:
                            'Get inspired and stay creative with your personal assistant powered by Stability Diffusion',
                      ),
                    ),
                    SlideInLeft(
                      delay: Duration(milliseconds: start + 2 * delay),
                      child: FeatureBox(
                        color: Pallete.thirdSuggestionBoxColor,
                        headerText: 'Smart Voice Assistant',
                        description:
                            'Get the best of both worlds with a voice assistant powered by Stability Diffusion and Gemini',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + 3 * delay),
        child: FloatingActionButton(
          backgroundColor: Pallete.firstSuggestionBoxColor,
          onPressed: () async {
            if (await speechToText.hasPermission &&
                speechToText.isNotListening) {
              await startListening();
            } else if (speechToText.isListening) {
              // Stop listening first
              await stopListening();
              
              // Show loading indicator
              setState(() {
                isLoading = true;
                loadingMessage = 'Processing your request...';
              });
              
              // Process the request
              try {
                final speech = await geminiServices.checkIfImageGeneration(
                  lastWords,
                );
                
                if (speech.contains('https')) {
                  setState(() {
                    loadingMessage = 'Generating image...';
                  });
                  generatedImageUrl = speech;
                  generatedContent = null;
                } else {
                  generatedImageUrl = null;
                  generatedContent = speech;
                  await systemSpeak(speech);
                }
              } catch (e) {
                generatedContent = 'Sorry, an error occurred: $e';
                generatedImageUrl = null;
              } finally {
                // Hide loading indicator
                setState(() {
                  isLoading = false;
                });
              }
            } else {
              initSpeechToText();
            }
          },
          child: Icon(speechToText.isListening ? Icons.stop : Icons.mic),
        ),
      ),
    );
  }
  
  Widget _buildLoadingIndicator({bool isImage = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Pallete.accentBlue),
            strokeWidth: 3,
          ),
        ),
        Text(
          isImage ? 'Creating your image...' : loadingMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cera Pro',
            color: Pallete.mainFontColor,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        if (!isImage)
          Text(
            'Using Gemini AI',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cera Pro',
              color: Pallete.accentBlue,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
