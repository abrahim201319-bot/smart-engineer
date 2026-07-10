#!/bin/bash
set -e

mkdir -p "lib"
cat > "lib/main.dart" << 'SMARTENG_EOF'
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const SmartEngineerApp(),
    ),
  );
}

class SmartEngineerApp extends StatelessWidget {
  const SmartEngineerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    return MaterialApp(
      title: 'مهندس ذكي',
      debugShowCheckedModeBanner: false,
      themeMode: themeController.mode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const HomeScreen(),
    );
  }
}
SMARTENG_EOF

mkdir -p "lib/models"
cat > "lib/models/project.dart" << 'SMARTENG_EOF'
class EngProject {
  final String id;
  final String name;
  final String location;
  final String engineerName;
  final DateTime createdAt;
  double progressPercent; // 0-100
  String notes;

  EngProject({
    required this.id,
    required this.name,
    required this.location,
    required this.engineerName,
    required this.createdAt,
    this.progressPercent = 0,
    this.notes = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'location': location,
        'engineerName': engineerName,
        'createdAt': createdAt.toIso8601String(),
        'progressPercent': progressPercent,
        'notes': notes,
      };

  factory EngProject.fromMap(Map<String, dynamic> m) => EngProject(
        id: m['id'] as String,
        name: m['name'] as String,
        location: m['location'] as String? ?? '',
        engineerName: m['engineerName'] as String? ?? '',
        createdAt: DateTime.parse(m['createdAt'] as String),
        progressPercent: (m['progressPercent'] as num?)?.toDouble() ?? 0,
        notes: m['notes'] as String? ?? '',
      );
}
SMARTENG_EOF

mkdir -p "lib/models"
cat > "lib/models/report.dart" << 'SMARTENG_EOF'
class DailyReport {
  final String id;
  final String projectId;
  final String projectName;
  final String engineerName;
  final DateTime date;
  final String executedWorks;
  final String labor;
  final String equipment;
  final String notes;
  final double completionPercent;
  final List<String> imagePaths;

  DailyReport({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.engineerName,
    required this.date,
    required this.executedWorks,
    required this.labor,
    required this.equipment,
    required this.notes,
    required this.completionPercent,
    required this.imagePaths,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'projectId': projectId,
        'projectName': projectName,
        'engineerName': engineerName,
        'date': date.toIso8601String(),
        'executedWorks': executedWorks,
        'labor': labor,
        'equipment': equipment,
        'notes': notes,
        'completionPercent': completionPercent,
        'imagePaths': imagePaths.join('|'),
      };

  factory DailyReport.fromMap(Map<String, dynamic> m) => DailyReport(
        id: m['id'] as String,
        projectId: m['projectId'] as String,
        projectName: m['projectName'] as String? ?? '',
        engineerName: m['engineerName'] as String? ?? '',
        date: DateTime.parse(m['date'] as String),
        executedWorks: m['executedWorks'] as String? ?? '',
        labor: m['labor'] as String? ?? '',
        equipment: m['equipment'] as String? ?? '',
        notes: m['notes'] as String? ?? '',
        completionPercent: (m['completionPercent'] as num?)?.toDouble() ?? 0,
        imagePaths: ((m['imagePaths'] as String?) ?? '')
            .split('|')
            .where((e) => e.trim().isNotEmpty)
            .toList(),
      );
}
SMARTENG_EOF

mkdir -p "lib/screens"
cat > "lib/screens/calculators_screen.dart" << 'SMARTENG_EOF'
import 'package:flutter/material.dart';

class CalculatorsScreen extends StatelessWidget {
  const CalculatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حاسبات هندسية'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'خرسانة'),
              Tab(text: 'بلاط'),
              Tab(text: 'بلوك'),
              Tab(text: 'طلاء'),
              Tab(text: 'تحويل وحدات'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ConcreteCalc(),
            _TileCalc(),
            _BlockCalc(),
            _PaintCalc(),
            _UnitConvertCalc(),
          ],
        ),
      ),
    );
  }
}

class _CalcShell extends StatelessWidget {
  final List<Widget> children;
  const _CalcShell({required this.children});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      );
}

Widget _resultCard(String label, String value) => Card(
      color: Colors.green.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
          ],
        ),
      ),
    );

// ---------------- حساب حجم الخرسانة ----------------
class _ConcreteCalc extends StatefulWidget {
  const _ConcreteCalc();
  @override
  State<_ConcreteCalc> createState() => _ConcreteCalcState();
}

class _ConcreteCalcState extends State<_ConcreteCalc> {
  final l = TextEditingController(), w = TextEditingController(), h = TextEditingController();
  double? volume;

  void _calc() {
    final ln = double.tryParse(l.text) ?? 0;
    final wn = double.tryParse(w.text) ?? 0;
    final hn = double.tryParse(h.text) ?? 0;
    setState(() => volume = ln * wn * hn);
  }

  @override
  Widget build(BuildContext context) {
    return _CalcShell(children: [
      const Text('حساب حجم الخرسانة (طول × عرض × ارتفاع)',
          style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      TextField(
          controller: l,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'الطول (متر)')),
      const SizedBox(height: 10),
      TextField(
          controller: w,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'العرض (متر)')),
      const SizedBox(height: 10),
      TextField(
          controller: h,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'الارتفاع/السماكة (متر)')),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _calc, child: const Text('احسب')),
      const SizedBox(height: 16),
      if (volume != null) _resultCard('حجم الخرسانة', '${volume!.toStringAsFixed(3)} م³'),
    ]);
  }
}

// ---------------- حساب مساحة البلاط ----------------
class _TileCalc extends StatefulWidget {
  const _TileCalc();
  @override
  State<_TileCalc> createState() => _TileCalcState();
}

class _TileCalcState extends State<_TileCalc> {
  final roomArea = TextEditingController();
  final tileL = TextEditingController(text: '0.6');
  final tileW = TextEditingController(text: '0.6');
  final waste = TextEditingController(text: '10');
  int? tileCount;
  double? areaWithWaste;

  void _calc() {
    final area = double.tryParse(roomArea.text) ?? 0;
    final tl = double.tryParse(tileL.text) ?? 0.01;
    final tw = double.tryParse(tileW.text) ?? 0.01;
    final wastePct = double.tryParse(waste.text) ?? 0;
    final tileArea = tl * tw;
    final totalArea = area * (1 + wastePct / 100);
    setState(() {
      areaWithWaste = totalArea;
      tileCount = (totalArea / tileArea).ceil();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _CalcShell(children: [
      const Text('حساب كمية بلاط الأرضية', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      TextField(
          controller: roomArea,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'مساحة الغرفة (م²)')),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
            child: TextField(
                controller: tileL,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'طول البلاطة (م)'))),
        const SizedBox(width: 10),
        Expanded(
            child: TextField(
                controller: tileW,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'عرض البلاطة (م)'))),
      ]),
      const SizedBox(height: 10),
      TextField(
          controller: waste,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'نسبة الهدر % (اقتراح 10%)')),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _calc, child: const Text('احسب')),
      const SizedBox(height: 16),
      if (tileCount != null) ...[
        _resultCard('المساحة شاملة الهدر', '${areaWithWaste!.toStringAsFixed(2)} م²'),
        const SizedBox(height: 8),
        _resultCard('عدد البلاط المطلوب', '$tileCount بلاطة'),
      ],
    ]);
  }
}

// ---------------- حساب كمية البلوك ----------------
class _BlockCalc extends StatefulWidget {
  const _BlockCalc();
  @override
  State<_BlockCalc> createState() => _BlockCalcState();
}

class _BlockCalcState extends State<_BlockCalc> {
  final wallL = TextEditingController();
  final wallH = TextEditingController();
  final blockL = TextEditingController(text: '0.4');
  final blockH = TextEditingController(text: '0.2');
  final waste = TextEditingController(text: '5');
  int? blockCount;

  void _calc() {
    final wl = double.tryParse(wallL.text) ?? 0;
    final wh = double.tryParse(wallH.text) ?? 0;
    final bl = double.tryParse(blockL.text) ?? 0.01;
    final bh = double.tryParse(blockH.text) ?? 0.01;
    final wastePct = double.tryParse(waste.text) ?? 0;
    final wallArea = wl * wh;
    final blockArea = bl * bh;
    final count = (wallArea / blockArea) * (1 + wastePct / 100);
    setState(() => blockCount = count.ceil());
  }

  @override
  Widget build(BuildContext context) {
    return _CalcShell(children: [
      const Text('حساب كمية البلوك للجدران', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      TextField(
          controller: wallL,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'طول الجدار (م)')),
      const SizedBox(height: 10),
      TextField(
          controller: wallH,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'ارتفاع الجدار (م)')),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
            child: TextField(
                controller: blockL,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'طول البلوكة (م)'))),
        const SizedBox(width: 10),
        Expanded(
            child: TextField(
                controller: blockH,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'ارتفاع البلوكة (م)'))),
      ]),
      const SizedBox(height: 10),
      TextField(
          controller: waste,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'نسبة الهدر % (اقتراح 5%)')),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _calc, child: const Text('احسب')),
      const SizedBox(height: 16),
      if (blockCount != null) _resultCard('عدد البلوك المطلوب', '$blockCount بلوكة'),
    ]);
  }
}

// ---------------- حساب الطلاء ----------------
class _PaintCalc extends StatefulWidget {
  const _PaintCalc();
  @override
  State<_PaintCalc> createState() => _PaintCalcState();
}

class _PaintCalcState extends State<_PaintCalc> {
  final area = TextEditingController();
  final coverage = TextEditingController(text: '10'); // م² لكل لتر تقريباً
  final coats = TextEditingController(text: '2');
  double? liters;

  void _calc() {
    final a = double.tryParse(area.text) ?? 0;
    final cov = double.tryParse(coverage.text) ?? 1;
    final c = double.tryParse(coats.text) ?? 1;
    setState(() => liters = (a * c) / cov);
  }

  @override
  Widget build(BuildContext context) {
    return _CalcShell(children: [
      const Text('حساب كمية الطلاء (الدهان)', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      TextField(
          controller: area,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'مساحة الجدران/السقف (م²)')),
      const SizedBox(height: 10),
      TextField(
          controller: coverage,
          keyboardType: TextInputType.number,
          decoration:
              const InputDecoration(labelText: 'معدل التغطية (م² لكل لتر)')),
      const SizedBox(height: 10),
      TextField(
          controller: coats,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'عدد طبقات الدهان')),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _calc, child: const Text('احسب')),
      const SizedBox(height: 16),
      if (liters != null) _resultCard('كمية الدهان المطلوبة', '${liters!.toStringAsFixed(2)} لتر'),
    ]);
  }
}

// ---------------- تحويل الوحدات ----------------
class _UnitConvertCalc extends StatefulWidget {
  const _UnitConvertCalc();
  @override
  State<_UnitConvertCalc> createState() => _UnitConvertCalcState();
}

class _UnitConvertCalcState extends State<_UnitConvertCalc> {
  final value = TextEditingController();
  String from = 'متر';
  String to = 'قدم';
  double? result;

  final units = {
    'متر': 1.0,
    'قدم': 0.3048,
    'بوصة': 0.0254,
    'سنتيمتر': 0.01,
    'ياردة': 0.9144,
    'كيلومتر': 1000.0,
  };

  void _calc() {
    final v = double.tryParse(value.text) ?? 0;
    final meters = v * (units[from] ?? 1);
    setState(() => result = meters / (units[to] ?? 1));
  }

  @override
  Widget build(BuildContext context) {
    return _CalcShell(children: [
      const Text('تحويل وحدات الطول', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      TextField(
          controller: value,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'القيمة')),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: from,
            items: units.keys
                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                .toList(),
            onChanged: (v) => setState(() => from = v!),
            decoration: const InputDecoration(labelText: 'من'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: to,
            items: units.keys
                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                .toList(),
            onChanged: (v) => setState(() => to = v!),
            decoration: const InputDecoration(labelText: 'إلى'),
          ),
        ),
      ]),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _calc, child: const Text('احسب')),
      const SizedBox(height: 16),
      if (result != null) _resultCard('الناتج', '${result!.toStringAsFixed(4)} $to'),
    ]);
  }
}
SMARTENG_EOF

mkdir -p "lib/screens"
cat > "lib/screens/camera_screen.dart" << 'SMARTENG_EOF'
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/watermark_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _ready = false;
  File? _lastPhoto;

  final _projectCtrl = TextEditingController(text: 'مشروع تجريبي');
  final _engineerCtrl = TextEditingController(text: 'المهندس');
  final _companyCtrl = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      _controller = CameraController(cameras.first, ResolutionPreset.high,
          enableAudio: false);
      await _controller!.initialize();
      if (mounted) setState(() => _ready = true);
    } catch (e) {
      debugPrint('camera init error: $e');
    }
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final shot = await _controller!.takePicture();
    final watermarked = await WatermarkService.addWatermark(
      original: File(shot.path),
      projectName: _projectCtrl.text.trim(),
      engineerName: _engineerCtrl.text.trim(),
      companyName: _companyCtrl.text.trim(),
    );
    setState(() => _lastPhoto = watermarked);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الكاميرا الهندسية')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller: _projectCtrl,
                  decoration: const InputDecoration(labelText: 'اسم المشروع'),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _engineerCtrl,
                  decoration: const InputDecoration(labelText: 'اسم المهندس'),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _companyCtrl,
                  decoration:
                      const InputDecoration(labelText: 'اسم الشركة (اختياري)'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _ready
                ? CameraPreview(_controller!)
                : const Center(child: CircularProgressIndicator()),
          ),
          if (_lastPhoto != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Image.file(_lastPhoto!, height: 100),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              onPressed: _ready ? _capture : null,
              icon: const Icon(Icons.camera),
              label: const Text('التقاط صورة مع العلامة المائية'),
            ),
          ),
        ],
      ),
    );
  }
}
SMARTENG_EOF

mkdir -p "lib/screens"
cat > "lib/screens/home_screen.dart" << 'SMARTENG_EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import 'projects_screen.dart';
import 'new_report_screen.dart';
import 'reports_list_screen.dart';
import 'calculators_screen.dart';
import 'camera_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.mode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مهندس ذكي'),
        actions: [
          IconButton(
            tooltip: 'الوضع الليلي',
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => themeController.toggle(!isDark),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          children: [
            _HomeTile(
              icon: Icons.description,
              title: 'تقرير يومي جديد',
              color: AppTheme.primary,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NewReportScreen())),
            ),
            _HomeTile(
              icon: Icons.folder_copy,
              title: 'التقارير المحفوظة',
              color: Colors.teal,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ReportsListScreen())),
            ),
            _HomeTile(
              icon: Icons.camera_alt,
              title: 'الكاميرا الهندسية',
              color: AppTheme.secondary,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CameraScreen())),
            ),
            _HomeTile(
              icon: Icons.calculate,
              title: 'حاسبات هندسية',
              color: Colors.indigo,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CalculatorsScreen())),
            ),
            _HomeTile(
              icon: Icons.apartment,
              title: 'إدارة المشاريع',
              color: Colors.brown,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProjectsScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _HomeTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
SMARTENG_EOF

mkdir -p "lib/screens"
cat > "lib/screens/new_report_screen.dart" << 'SMARTENG_EOF'
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../models/report.dart';
import '../services/database_service.dart';
import 'report_detail_screen.dart';

class NewReportScreen extends StatefulWidget {
  const NewReportScreen({super.key});

  @override
  State<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  final _formKey = GlobalKey<FormState>();
  List<EngProject> _projects = [];
  EngProject? _selectedProject;

  final _engineerCtrl = TextEditingController();
  final _worksCtrl = TextEditingController();
  final _laborCtrl = TextEditingController();
  final _equipCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  double _completion = 0;
  final List<String> _images = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final list = await DatabaseService.instance.getProjects();
    setState(() {
      _projects = list;
      if (list.isNotEmpty) _selectedProject = list.first;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) setState(() => _images.add(picked.path));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (_selectedProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار مشروع أولاً')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final report = DailyReport(
      id: const Uuid().v4(),
      projectId: _selectedProject!.id,
      projectName: _selectedProject!.name,
      engineerName: _engineerCtrl.text.trim(),
      date: _date,
      executedWorks: _worksCtrl.text.trim(),
      labor: _laborCtrl.text.trim(),
      equipment: _equipCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      completionPercent: _completion,
      imagePaths: _images,
    );

    await DatabaseService.instance.insertReport(report);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ReportDetailScreen(report: report)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تقرير يومي جديد')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_projects.isEmpty)
              const Text('لا توجد مشاريع، الرجاء إنشاء مشروع أولاً من قسم إدارة المشاريع')
            else
              DropdownButtonFormField<EngProject>(
                value: _selectedProject,
                decoration: const InputDecoration(labelText: 'اسم المشروع'),
                items: _projects
                    .map((p) =>
                        DropdownMenuItem(value: p, child: Text(p.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedProject = v),
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _engineerCtrl,
              decoration: const InputDecoration(labelText: 'اسم المهندس'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                  'التاريخ: ${_date.year}/${_date.month}/${_date.day}'),
              trailing: const Icon(Icons.calendar_month),
              onTap: _pickDate,
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _worksCtrl,
              maxLines: 3,
              decoration:
                  const InputDecoration(labelText: 'الأعمال المنفذة'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _laborCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: 'العمالة (العدد والتخصصات)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _equipCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'المعدات المستخدمة'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'الملاحظات'),
            ),
            const SizedBox(height: 16),
            Text('نسبة الإنجاز: ${_completion.toStringAsFixed(0)}%',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _completion,
              min: 0,
              max: 100,
              divisions: 20,
              onChanged: (v) => setState(() => _completion = v),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('إضافة صورة من الموقع'),
            ),
            const SizedBox(height: 10),
            if (_images.isNotEmpty)
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(_images[i]),
                        width: 90, height: 90, fit: BoxFit.cover),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('حفظ التقرير'),
            ),
          ],
        ),
      ),
    );
  }
}
SMARTENG_EOF

mkdir -p "lib/screens"
cat > "lib/screens/project_detail_screen.dart" << 'SMARTENG_EOF'
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../services/database_service.dart';

class ProjectDetailScreen extends StatefulWidget {
  final EngProject project;
  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late TextEditingController _notesCtrl;
  late double _progress;
  List<Map<String, dynamic>> _images = [];

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController(text: widget.project.notes);
    _progress = widget.project.progressPercent;
    _loadImages();
  }

  Future<void> _loadImages() async {
    final imgs =
        await DatabaseService.instance.getProjectImages(widget.project.id);
    setState(() => _images = imgs);
  }

  Future<void> _saveChanges() async {
    widget.project.notes = _notesCtrl.text.trim();
    widget.project.progressPercent = _progress;
    await DatabaseService.instance.updateProject(widget.project);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تم حفظ التعديلات')));
    }
  }

  Future<void> _addImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;
    await DatabaseService.instance.addProjectImage(
      const Uuid().v4(),
      widget.project.id,
      picked.path,
      '',
    );
    _loadImages();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return Scaffold(
      appBar: AppBar(title: Text(p.name)),
      floatingActionButton: FloatingActionButton(
        onPressed: _addImage,
        child: const Icon(Icons.add_a_photo),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الموقع: ${p.location}'),
                  const SizedBox(height: 4),
                  Text('المهندس المسؤول: ${p.engineerName}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('نسبة الإنجاز', style: TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: _progress,
            min: 0,
            max: 100,
            divisions: 20,
            label: '${_progress.toStringAsFixed(0)}%',
            onChanged: (v) => setState(() => _progress = v),
          ),
          const SizedBox(height: 10),
          const Text('ملاحظات', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: _notesCtrl,
            maxLines: 4,
            decoration:
                const InputDecoration(hintText: 'أضف ملاحظاتك هنا...'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _saveChanges,
            icon: const Icon(Icons.save),
            label: const Text('حفظ التعديلات'),
          ),
          const SizedBox(height: 20),
          const Text('صور المشروع', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _images.isEmpty
              ? const Text('لا توجد صور بعد')
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, crossAxisSpacing: 6, mainAxisSpacing: 6),
                  itemCount: _images.length,
                  itemBuilder: (context, i) {
                    final path = _images[i]['path'] as String;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(path), fit: BoxFit.cover),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
SMARTENG_EOF

mkdir -p "lib/screens"
cat > "lib/screens/projects_screen.dart" << 'SMARTENG_EOF'
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../services/database_service.dart';
import 'project_detail_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<EngProject> _projects = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await DatabaseService.instance.getProjects();
    setState(() => _projects = list);
  }

  Future<void> _addProjectDialog() async {
    final nameCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    final engCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('مشروع جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'اسم المشروع')),
            const SizedBox(height: 10),
            TextField(
                controller: locCtrl,
                decoration: const InputDecoration(labelText: 'الموقع')),
            const SizedBox(height: 10),
            TextField(
                controller: engCtrl,
                decoration:
                    const InputDecoration(labelText: 'اسم المهندس المسؤول')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حفظ')),
        ],
      ),
    );

    if (result == true && nameCtrl.text.trim().isNotEmpty) {
      final project = EngProject(
        id: const Uuid().v4(),
        name: nameCtrl.text.trim(),
        location: locCtrl.text.trim(),
        engineerName: engCtrl.text.trim(),
        createdAt: DateTime.now(),
      );
      await DatabaseService.instance.insertProject(project);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المشاريع')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProjectDialog,
        icon: const Icon(Icons.add),
        label: const Text('مشروع جديد'),
      ),
      body: _projects.isEmpty
          ? const Center(child: Text('لا توجد مشاريع بعد، أضف مشروعك الأول'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _projects.length,
              itemBuilder: (context, i) {
                final p = _projects[i];
                return Card(
                  child: ListTile(
                    title: Text(p.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${p.location}\nنسبة الإنجاز: ${p.progressPercent.toStringAsFixed(0)}%'),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProjectDetailScreen(project: p)),
                      );
                      _load();
                    },
                  ),
                );
              },
            ),
    );
  }
}
SMARTENG_EOF

mkdir -p "lib/screens"
cat > "lib/screens/report_detail_screen.dart" << 'SMARTENG_EOF'
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/report.dart';
import '../services/pdf_service.dart';
import '../services/excel_service.dart';

class ReportDetailScreen extends StatefulWidget {
  final DailyReport report;
  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  bool _loading = false;

  Future<void> _exportPdf() async {
    setState(() => _loading = true);
    try {
      final file = await PdfService.buildReportPdf(widget.report);
      await Share.shareXFiles([XFile(file.path)],
          text: 'تقرير يومي - ${widget.report.projectName}');
    } catch (e) {
      _showError('تعذر إنشاء ملف PDF: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _exportExcel() async {
    setState(() => _loading = true);
    try {
      final file = await ExcelService.buildReportExcel(widget.report);
      await Share.shareXFiles([XFile(file.path)],
          text: 'تقرير يومي - ${widget.report.projectName}');
    } catch (e) {
      _showError('تعذر إنشاء ملف Excel: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.report;
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل التقرير')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.projectName,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text('المهندس: ${r.engineerName}'),
                        Text('التاريخ: ${DateFormat('yyyy/MM/dd').format(r.date)}'),
                        Text('نسبة الإنجاز: ${r.completionPercent.toStringAsFixed(0)}%'),
                      ],
                    ),
                  ),
                ),
                _detailCard('الأعمال المنفذة', r.executedWorks),
                _detailCard('العمالة', r.labor),
                _detailCard('المعدات', r.equipment),
                _detailCard('الملاحظات', r.notes),
                if (r.imagePaths.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text('صور الموقع',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6),
                    itemCount: r.imagePaths.length,
                    itemBuilder: (context, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(r.imagePaths[i]), fit: BoxFit.cover),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _exportPdf,
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('تصدير PDF'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _exportExcel,
                        icon: const Icon(Icons.table_chart),
                        label: const Text('تصدير Excel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _detailCard(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(content.isEmpty ? '-' : content),
          ],
        ),
      ),
    );
  }
}
SMARTENG_EOF

mkdir -p "lib/screens"
cat > "lib/screens/reports_list_screen.dart" << 'SMARTENG_EOF'
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/report.dart';
import '../services/database_service.dart';
import 'report_detail_screen.dart';

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({super.key});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  List<DailyReport> _reports = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await DatabaseService.instance.getReports();
    setState(() => _reports = list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التقارير المحفوظة')),
      body: _reports.isEmpty
          ? const Center(child: Text('لا توجد تقارير محفوظة بعد'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _reports.length,
              itemBuilder: (context, i) {
                final r = _reports[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${r.completionPercent.toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 11)),
                    ),
                    title: Text(r.projectName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${r.engineerName} • ${DateFormat('yyyy/MM/dd').format(r.date)}'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ReportDetailScreen(report: r)),
                      );
                      _load();
                    },
                  ),
                );
              },
            ),
    );
  }
}
SMARTENG_EOF

mkdir -p "lib/services"
cat > "lib/services/database_service.dart" << 'SMARTENG_EOF'
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/project.dart';
import '../models/report.dart';

class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();
  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smart_engineer.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE projects (
            id TEXT PRIMARY KEY,
            name TEXT,
            location TEXT,
            engineerName TEXT,
            createdAt TEXT,
            progressPercent REAL,
            notes TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE reports (
            id TEXT PRIMARY KEY,
            projectId TEXT,
            projectName TEXT,
            engineerName TEXT,
            date TEXT,
            executedWorks TEXT,
            labor TEXT,
            equipment TEXT,
            notes TEXT,
            completionPercent REAL,
            imagePaths TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE project_images (
            id TEXT PRIMARY KEY,
            projectId TEXT,
            path TEXT,
            note TEXT,
            createdAt TEXT
          )
        ''');
      },
    );
  }

  // ---------------- Projects ----------------
  Future<void> insertProject(EngProject p) async {
    final db = await database;
    await db.insert('projects', p.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateProject(EngProject p) async {
    final db = await database;
    await db.update('projects', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<List<EngProject>> getProjects() async {
    final db = await database;
    final rows = await db.query('projects', orderBy: 'createdAt DESC');
    return rows.map((e) => EngProject.fromMap(e)).toList();
  }

  Future<void> deleteProject(String id) async {
    final db = await database;
    await db.delete('projects', where: 'id = ?', whereArgs: [id]);
    await db.delete('reports', where: 'projectId = ?', whereArgs: [id]);
    await db.delete('project_images', where: 'projectId = ?', whereArgs: [id]);
  }

  Future<void> addProjectImage(
      String id, String projectId, String path, String note) async {
    final db = await database;
    await db.insert('project_images', {
      'id': id,
      'projectId': projectId,
      'path': path,
      'note': note,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getProjectImages(String projectId) async {
    final db = await database;
    return db.query('project_images',
        where: 'projectId = ?', whereArgs: [projectId], orderBy: 'createdAt DESC');
  }

  // ---------------- Reports ----------------
  Future<void> insertReport(DailyReport r) async {
    final db = await database;
    await db.insert('reports', r.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<DailyReport>> getReports({String? projectId}) async {
    final db = await database;
    final rows = await db.query(
      'reports',
      where: projectId != null ? 'projectId = ?' : null,
      whereArgs: projectId != null ? [projectId] : null,
      orderBy: 'date DESC',
    );
    return rows.map((e) => DailyReport.fromMap(e)).toList();
  }

  Future<void> deleteReport(String id) async {
    final db = await database;
    await db.delete('reports', where: 'id = ?', whereArgs: [id]);
  }
}
SMARTENG_EOF

mkdir -p "lib/services"
cat > "lib/services/excel_service.dart" << 'SMARTENG_EOF'
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/report.dart';

class ExcelService {
  static Future<File> buildReportExcel(DailyReport r) async {
    final excel = Excel.createExcel();
    final sheetName = 'التقرير اليومي';
    final sheet = excel[sheetName];
    excel.setDefaultSheet(sheetName);
    // حذف الشيت الافتراضي إن وُجد باسم مختلف
    if (excel.sheets.containsKey('Sheet1') && sheetName != 'Sheet1') {
      excel.delete('Sheet1');
    }

    final dateStr = DateFormat('yyyy/MM/dd').format(r.date);

    final rows = <List<Object>>[
      ['البند', 'القيمة'],
      ['اسم المشروع', r.projectName],
      ['اسم المهندس', r.engineerName],
      ['التاريخ', dateStr],
      ['نسبة الإنجاز (%)', r.completionPercent.toStringAsFixed(0)],
      ['الأعمال المنفذة', r.executedWorks],
      ['العمالة', r.labor],
      ['المعدات', r.equipment],
      ['الملاحظات', r.notes],
      ['عدد الصور المرفقة', r.imagePaths.length.toString()],
    ];

    for (final row in rows) {
      sheet.appendRow(row.map((e) => TextCellValue(e.toString())).toList());
    }

    sheet.setColumnWidth(0, 24);
    sheet.setColumnWidth(1, 50);

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/report_${r.id}.xlsx');
    final bytes = excel.encode();
    await file.writeAsBytes(bytes!);
    return file;
  }
}
SMARTENG_EOF

mkdir -p "lib/services"
cat > "lib/services/pdf_service.dart" << 'SMARTENG_EOF'
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/report.dart';

class PdfService {
  static Future<File> buildReportPdf(DailyReport r) async {
    final doc = pw.Document();

    // خط عربي (Noto Naskh Arabic) - ضعه في assets/fonts حسب التعليمات في الشرح
    final regularData =
        await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf');
    final boldData =
        await rootBundle.load('assets/fonts/NotoNaskhArabic-Bold.ttf');
    final arabicFont = pw.Font.ttf(regularData);
    final arabicBold = pw.Font.ttf(boldData);

    final dateStr = DateFormat('yyyy/MM/dd').format(r.date);

    final images = <pw.MemoryImage>[];
    for (final p in r.imagePaths) {
      final f = File(p);
      if (await f.exists()) {
        images.add(pw.MemoryImage(await f.readAsBytes()));
      }
    }

    doc.addPage(
      pw.MultiPage(
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicBold),
        build: (context) => [
          pw.Center(
            child: pw.Text('تقرير العمل اليومي',
                style: pw.TextStyle(font: arabicBold, fontSize: 22)),
          ),
          pw.SizedBox(height: 16),
          _row('اسم المشروع', r.projectName, arabicFont, arabicBold),
          _row('اسم المهندس', r.engineerName, arabicFont, arabicBold),
          _row('التاريخ', dateStr, arabicFont, arabicBold),
          _row('نسبة الإنجاز', '${r.completionPercent.toStringAsFixed(0)}%',
              arabicFont, arabicBold),
          pw.SizedBox(height: 10),
          _section('الأعمال المنفذة', r.executedWorks, arabicFont, arabicBold),
          _section('العمالة', r.labor, arabicFont, arabicBold),
          _section('المعدات', r.equipment, arabicFont, arabicBold),
          _section('الملاحظات', r.notes, arabicFont, arabicBold),
          if (images.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Text('صور الموقع',
                style: pw.TextStyle(font: arabicBold, fontSize: 16)),
            pw.SizedBox(height: 8),
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: images
                  .map((img) => pw.Container(
                      width: 150, height: 150, child: pw.Image(img)))
                  .toList(),
            ),
          ],
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/report_${r.id}.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  static pw.Widget _row(
      String label, String value, pw.Font font, pw.Font bold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('$label:', style: pw.TextStyle(font: bold, fontSize: 13)),
          pw.Text(value, style: pw.TextStyle(font: font, fontSize: 13)),
        ],
      ),
    );
  }

  static pw.Widget _section(
      String title, String content, pw.Font font, pw.Font bold) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      width: double.infinity,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(font: bold, fontSize: 13)),
          pw.SizedBox(height: 4),
          pw.Text(content.isEmpty ? '-' : content,
              style: pw.TextStyle(font: font, fontSize: 12)),
        ],
      ),
    );
  }
}
SMARTENG_EOF

mkdir -p "lib/services"
cat > "lib/services/watermark_service.dart" << 'SMARTENG_EOF'
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// خدمة إضافة علامة مائية هندسية على الصور:
/// التاريخ/الوقت + اسم المشروع + اسم المهندس + (شعار اختياري)
class WatermarkService {
  static Future<File> addWatermark({
    required File original,
    required String projectName,
    required String engineerName,
    String? companyName,
    DateTime? dateTime,
  }) async {
    final bytes = await original.readAsBytes();
    img.Image? photo = img.decodeImage(bytes);
    if (photo == null) return original;

    final dt = dateTime ?? DateTime.now();
    final dateStr = DateFormat('yyyy/MM/dd  HH:mm').format(dt);

    final lines = <String>[
      'المشروع: $projectName',
      'المهندس: $engineerName',
      dateStr,
      if (companyName != null && companyName.trim().isNotEmpty) companyName,
    ];

    // شريط شبه شفاف أسفل الصورة لتحسين وضوح النص
    final bandHeight = 34 * lines.length + 20;
    final bandY = photo.height - bandHeight;
    if (bandY > 0) {
      img.fillRect(
        photo,
        x1: 0,
        y1: bandY,
        x2: photo.width,
        y2: photo.height,
        color: img.ColorRgba8(0, 0, 0, 130),
      );
    }

    int ty = (bandY > 0 ? bandY : photo.height - bandHeight) + 10;
    for (final line in lines) {
      img.drawString(
        photo,
        line,
        font: img.arial24,
        x: 16,
        y: ty,
        color: img.ColorRgb8(255, 255, 255),
      );
      ty += 34;
    }

    final dir = await getApplicationDocumentsDirectory();
    final outPath =
        '${dir.path}/wm_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final outFile = File(outPath);
    await outFile.writeAsBytes(img.encodeJpg(photo, quality: 90));
    return outFile;
  }
}
SMARTENG_EOF

mkdir -p "lib/theme"
cat > "lib/theme/app_theme.dart" << 'SMARTENG_EOF'
import 'package:flutter/material.dart';

class AppTheme {
  // لون هندسي أساسي (أزرق فولاذي) + لون برتقالي (خوذة السلامة) كلون ثانوي
  static const Color primary = Color(0xFF0D3B66);
  static const Color secondary = Color(0xFFF4A300);
  static const Color bgLight = Color(0xFFF5F7FA);

  static ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: 'NotoNaskhArabic',
    brightness: Brightness.light,
    scaffoldBackgroundColor: bgLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      secondary: secondary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    fontFamily: 'NotoNaskhArabic',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121417),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      secondary: secondary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0A1F33),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: const Color(0xFF1C1F24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondary,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1C1F24),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}

/// إشعار بسيط للتحكم بالوضع الليلي عالمياً
class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  void toggle(bool isDark) {
    _mode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
SMARTENG_EOF

cat > "pubspec.yaml" << 'SMARTENG_EOF'
name: smart_engineer
description: "مهندس ذكي - تطبيق مساعد للمهندس المدني في الموقع"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  cupertino_icons: ^1.0.6

  # قاعدة بيانات محلية مجانية (لا تحتاج إنترنت ولا Firebase مدفوع)
  sqflite: ^2.3.3+1
  path: ^1.9.0
  path_provider: ^2.1.3

  # الكاميرا والصور
  camera: ^0.11.0+2
  image: ^4.2.0
  image_picker: ^1.1.2

  # التصدير
  pdf: ^3.11.1
  printing: ^5.13.1
  excel: ^4.0.3
  share_plus: ^10.0.2

  # عام
  intl: ^0.19.0
  provider: ^6.1.2
  uuid: ^4.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/fonts/
  fonts:
    - family: NotoNaskhArabic
      fonts:
        - asset: assets/fonts/NotoNaskhArabic-Regular.ttf
        - asset: assets/fonts/NotoNaskhArabic-Bold.ttf
          weight: 700
SMARTENG_EOF

mkdir -p "assets/fonts"
curl -L -o "assets/fonts/NotoNaskhArabic-Regular.ttf" "https://github.com/jenskutilek/free-fonts/raw/refs/heads/master/Noto/Noto%20Naskh%20Arabic/TTF/NotoNaskhArabic-Regular.ttf"
curl -L -o "assets/fonts/NotoNaskhArabic-Bold.ttf" "https://github.com/jenskutilek/free-fonts/raw/refs/heads/master/Noto/Noto%20Naskh%20Arabic/TTF/NotoNaskhArabic-Bold.ttf"

git add -A
git commit -m "إضافة كامل ملفات مشروع مهندس ذكي"
git push
echo "تم بنجاح! كل الملفات مرفوعة."
