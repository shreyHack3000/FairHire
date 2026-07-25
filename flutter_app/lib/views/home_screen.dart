import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/audit_models.dart';
import '../services/api_service.dart';
import '../widgets/header_bar.dart';
import '../widgets/file_upload_card.dart';
import '../widgets/audit_results_view.dart';
import '../widgets/audit_history_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isBackendHealthy = false;
  bool _isCheckingBackend = true;
  bool _isAuditing = false;

  AuditReport? _currentReport;
  String? _errorMessage;

  List<AuditHistoryItem> _historyItems = [];
  bool _isLoadingHistory = false;

  // Sample CSV embedded for single-click Quick Audit demo
  static const String _sampleCsvData = '''Candidate Id,Name,College,College tier,City,Skills,Years exp,selected
STU19CSE483,Rahul Verma,IIT Delhi,1,Delhi,"Python,ML,Data Analysis",2,1
STU18CSE017,Sneha Iyer,NIT Trichy,1,Tiruchirappalli,"Python,ML,Data Analysis",2,1
STU20CSE392,Arjun Mehta,IIT Bombay,1,Bombay,"Python,ML,Data Analysis",2,1
STU19CSE105,Priya Sharma,NIT Surathkal,1,Surathkal,"Python,ML,Data Analysis",2,1
STU18CSE276,Karan Patel,IIT Kanpur,1,Kanpur,"Python,ML,Data Analysis",2,1
STU20CSE451,Ananya Das,NIT Warangal,1,Warangal,"Python,ML,Data Analysis",2,1
STU19CSE089,Rohit Singh,IIT Kharagpur,1,Kharagpur,"Python,ML,Data Analysis",2,1
STU18CSE334,Neha Gupta,NIT Calicut,1,Calicut,"Python,ML,Data Analysis",2,1
STU20CSE512,Aditya Rao,IIT Madras,1,Chennai,"Python,ML,Data Analysis",2,1
STU19CSE063,Pooja Kulkarni,NIT Nagpur,1,Nagpur,"Python,ML,Data Analysis",2,0
STU18CSE248,Vikram Joshi,IIT Roorkee,1,Roorkee,"Python,ML,Data Analysis",2,1
STU20CSE019,Simran Kaur,NIT Jalandhar,1,Jalandhar,"Python,ML,Data Analysis",2,0
STU19CSE367,Aman Khan,NIT Durgapur,1,Durgapur,"Python,ML,Data Analysis",2,0
STU18CSE290,Riya Chatterjee,IIT GUWAHATI,1,Guwahati,"Python,ML,Data Analysis",2,1
STU20CSE441,Saurabh Mishra,IIT Hyderabad,1,Hyderabad,"Python,ML,Data Analysis",2,1
STU19CSE156,Rohan Malhotra,DTU,2,Delhi,"Python,ML,Data Analysis",2,1
STU18CSE078,Kavya Nair,VIT Vellore,2,Vellore,"Python,ML,Data Analysis",2,1
STU20CSE509,Siddharth Jain,DTU,2,Delhi,"Python,ML,Data Analysis",2,1
STU19CSE314,Meera Reddy,VIT Chennai,2,Chennai,"Python,ML,Data Analysis",2,0
STU18CSE422,Abhishek Banerjee,SRM Kattankulathur,2,Kattankulathur,"Python,ML,Data Analysis",2,0
STU20CSE189,Isha Agarwal,DTU,2,Delhi,"Python,ML,Data Analysis",2,1
STU19CSE231,Nikhil Kumar,VIT Vellore,2,Vellore,"Python,ML,Data Analysis",2,0
STU18CSE115,Divya Saxena,Manipal University,2,Manipal,"Python,ML,Data Analysis",2,0
STU20CSE304,Varun Kapoor,DTU,2,Delhi,"Python,ML,Data Analysis",2,1
STU19CSE477,Tanvi Bhatt,VIT Chennai,2,Chennai,"Python,ML,Data Analysis",2,0
STU18CSE092,Gaurav Sharma,SRM Kattankulathur,2,Kattankulathur,"Python,ML,Data Analysis",2,0
STU20CSE213,Shweta Pandey,Thapar Institute,2,Patiala,"Python,ML,Data Analysis",2,0
STU19CSE388,Yash Chopra,BITS Pilani,2,Pilani,"Python,ML,Data Analysis",2,1
STU18CSE561,Anjali Tripathi,VIT Vellore,2,Vellore,"Python,ML,Data Analysis",2,0
STU20CSE142,Harsh Vardhan,DTU,2,Delhi,"Python,ML,Data Analysis",2,0
STU19CSE024,Shruti Sen,LPU,3,Phagwara,"Python,ML,Data Analysis",2,0
STU18CSE399,Rajesh Choudhury,CU,3,Gharuan,"Python,ML,Data Analysis",2,0
STU20CSE287,Preeti Deshmukh,Sathyabama,3,Chennai,"Python,ML,Data Analysis",2,0
STU19CSE112,Deepak Yadav,Amity University,3,Noida,"Python,ML,Data Analysis",2,0
STU18CSE453,Swati Verma,Galgotias,3,Greater Noida,"Python,ML,Data Analysis",2,0
STU20CSE098,Alok Srivastava,Sharda University,3,Greater Noida,"Python,ML,Data Analysis",2,0
STU19CSE341,Kiran Goswami,LPU,3,Phagwara,"Python,ML,Data Analysis",2,0
STU18CSE206,Tarun Bhasin,CU,3,Gharuan,"Python,ML,Data Analysis",2,0
STU20CSE488,Monika Thakur,Amity University,3,Noida,"Python,ML,Data Analysis",2,0
STU19CSE175,Sanjay Dutta,Graphic Era,3,Dehradun,"Python,ML,Data Analysis",2,0
STU18CSE319,Richa Upadhyay,LPU,3,Phagwara,"Python,ML,Data Analysis",2,0
STU20CSE064,Manish Tiwari,CU,3,Gharuan,"Python,ML,Data Analysis",2,0
STU19CSE429,Pallavi Rathi,Amity University,3,Noida,"Python,ML,Data Analysis",2,0
STU18CSE181,Vineet Saxena,SRM Ramapuram,3,Chennai,"Python,ML,Data Analysis",2,0
STU20CSE355,Nidhi Shukla,LPU,3,Phagwara,"Python,ML,Data Analysis",2,0
STU19CSE260,Prateek Rastogi,CU,3,Gharuan,"Python,ML,Data Analysis",2,0
STU18CSE494,Bhavna Mahajan,Amity University,3,Noida,"Python,ML,Data Analysis",2,0
STU20CSE127,Rakesh Soni,LPU,3,Phagwara,"Python,ML,Data Analysis",2,0
STU19CSE302,Archana Prasad,CU,3,Gharuan,"Python,ML,Data Analysis",2,0
STU18CSE538,Siddharth Menon,Amity University,3,Noida,"Python,ML,Data Analysis",2,0''';

  @override
  void initState() {
    super.initState();
    _checkBackendHealth();
    _fetchHistory();
  }

  Future<void> _checkBackendHealth() async {
    setState(() => _isCheckingBackend = true);
    final healthy = await ApiService.checkBackendHealth();
    if (mounted) {
      setState(() {
        _isBackendHealthy = healthy;
        _isCheckingBackend = false;
      });
    }
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoadingHistory = true);
    final items = await ApiService.fetchAuditHistory();
    if (mounted) {
      setState(() {
        _historyItems = items;
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _runAudit(Uint8List fileBytes, String filename) async {
    setState(() {
      _isAuditing = true;
      _errorMessage = null;
    });

    try {
      final report = await ApiService.uploadAndAuditCsv(fileBytes, filename);
      if (mounted) {
        setState(() {
          _currentReport = report;
          _isAuditing = false;
        });
        _fetchHistory(); // Refresh audit logs from Supabase
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isAuditing = false;
        });
      }
    }
  }

  void _runSampleAudit() {
    final bytes = Uint8List.fromList(utf8.encode(_sampleCsvData));
    _runAudit(bytes, 'sample_hiring_data.csv');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0B0F19),
      drawer: AuditHistoryDrawer(
        historyItems: _historyItems,
        isLoading: _isLoadingHistory,
        onRefresh: _fetchHistory,
      ),
      body: SafeArea(
        child: Column(
          children: [
            HeaderBar(
              isBackendHealthy: _isBackendHealthy,
              isCheckingBackend: _isCheckingBackend,
              onRefreshHealth: _checkBackendHealth,
              onOpenHistory: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Text Section
                        if (_currentReport == null) ...[
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF1E1B4B).withOpacity(0.8),
                                  const Color(0xFF0F172A).withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF6366F1).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.security,
                                              color: Color(0xFF818CF8),
                                              size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            'PREVENT AI BIAS DISPARITY BEFORE PRODUCTION',
                                            style: TextStyle(
                                              color: const Color(0xFFA5B4FC),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Audit Candidate Datasets with Pentest Precision',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 26,
                                          fontWeight: FontWeight.extrabold,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'FairHire analyzes candidate selection ratios across College Tiers, Name/Ethnicity proxies, and Locations. Generates CVSS-style vulnerability reports paired with batched Google Gemini AI fixes.',
                                        style: TextStyle(
                                          color: Color(0xFFCBD5E1),
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Error Banner if Audit failed
                        if (_errorMessage != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFEF4444).withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Color(0xFFF87171), size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Audit Failed: $_errorMessage',
                                    style: const TextStyle(
                                      color: Color(0xFFF87171),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Main Content: Upload Card OR Audit Results View
                        if (_currentReport == null)
                          FileUploadCard(
                            onFileSelected: _runAudit,
                            onLoadSample: _runSampleAudit,
                            isAuditing: _isAuditing,
                          )
                        else
                          AuditResultsView(
                            report: _currentReport!,
                            onNewAudit: () {
                              setState(() {
                                _currentReport = null;
                                _errorMessage = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
