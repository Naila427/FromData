import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Halaman_Utama extends StatefulWidget {
  const Halaman_Utama({super.key});

  @override
  State<Halaman_Utama> createState() => _Halaman_UtamaState();
}

class _Halaman_UtamaState extends State<Halaman_Utama> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _npmController = TextEditingController();
  final TextEditingController _telpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final List<String> _prodiList = ['Informatika', 'Mesin', 'Elektro', 'Sipil'];
  final List<String> _kelasList = ['A', 'B', 'C', 'D'];
  final List<int> _semesterList = [1, 2, 3, 4, 5, 6, 7, 8];

  String? _selectedProdi;
  String? _selectedKelas;
  int? _selectedSemester;
  String _jenisKelamin = 'Perempuan';

  List<Map<String, dynamic>> _items = [];
  static const String _prefsKey = 'submissions';
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _npmController.dispose();
    _telpController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey);

    if (raw != null) {
      setState(() {
        _items = raw.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
      });
    }
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _items.map((m) => jsonEncode(m)).toList();
    await prefs.setStringList(_prefsKey, raw);
  }

  void _clearForm() {
    _namaController.clear();
    _alamatController.clear();
    _npmController.clear();
    _telpController.clear();
    _emailController.clear();
    setState(() {
      _selectedProdi = null;
      _selectedKelas = null;
      _selectedSemester = null;
      _jenisKelamin = 'Perempuan';
      _editingIndex = null;
    });
  }

  void _addOrUpdateItem() {
    final nama = _namaController.text.trim();
    final npm = _npmController.text.trim();
    final alamat = _alamatController.text.trim();
    final telp = _telpController.text.trim();

    final emailInput = _emailController.text.trim();
    final email = emailInput.endsWith('@gmail.com')
        ? emailInput
        : '$emailInput@gmail.com';

    if (nama.isEmpty || npm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama dan NPM wajib diisi")),
      );
      return;
    }

    final data = {
      'nama': nama,
      'npm': npm,
      'alamat': alamat,
      'prodi': _selectedProdi ?? '-',
      'kelas': _selectedKelas ?? '-',
      'semester': _selectedSemester?.toString() ?? '-',
      'jk': _jenisKelamin,
      'telp': telp,
      'email': email,
    };

    if (_editingIndex == null) {
      data['createdAt'] = DateTime.now().toIso8601String();
      setState(() => _items.insert(0, data));
    } else {
      data['createdAt'] = _items[_editingIndex!]['createdAt'];
      data['updatedAt'] = DateTime.now().toIso8601String();
      setState(() {
        _items[_editingIndex!] = data;
        _editingIndex = null;
      });
    }

    _saveAll();
    _clearForm();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_editingIndex == null ? "Data ditambahkan" : "Data diperbarui")),
    );
  }

  void _startEdit(int index) {
    final item = _items[index];
    setState(() {
      _editingIndex = index;
      _namaController.text = item['nama'];
      _npmController.text = item['npm'];
      _alamatController.text = item['alamat'];
      _selectedProdi = item['prodi'];
      _selectedKelas = item['kelas'];
      _selectedSemester = int.tryParse(item['semester'].toString());
      _jenisKelamin = item['jk'];
      _telpController.text = item['telp'] ?? '';
      _emailController.text =
          (item['email'] ?? '').replaceAll('@gmail.com', '');
    });
  }

  Future<void> _removeItem(int index) async {
    setState(() => _items.removeAt(index));
    await _saveAll();
  }

  void _showDetail(Map<String, dynamic> item, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Detail Data"),
        content: Text(
          'Nama: ${item['nama']}\n'
          'NPM: ${item['npm']}\n'
          'Alamat: ${item['alamat']}\n'
          'Prodi: ${item['prodi']}\n'
          'Kelas: ${item['kelas']}\n'
          'Semester: ${item['semester']}\n'
          'Jenis Kelamin: ${item['jk']}\n'
          'No. Telp: ${item['telp']}\n'
          'Email: ${item['email']}\n\n'
          'Dibuat: ${item['createdAt'] ?? '-'}\n'
          'Diupdate: ${item['updatedAt'] ?? '-'}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startEdit(index);
            },
            child: const Text("Edit"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeItem(index);
            },
            child: const Text("Hapus"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Diri")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _namaController, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Nama")),
            const SizedBox(height: 12),

            TextField(controller: _npmController, keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "NPM")),
            const SizedBox(height: 12),

            TextField(controller: _alamatController, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Alamat")),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Prodi"),
              value: _selectedProdi,
              items: _prodiList.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) => setState(() => _selectedProdi = v),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Kelas"),
              value: _selectedKelas,
              items: _kelasList.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
              onChanged: (v) => setState(() => _selectedKelas = v),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Semester"),
              value: _selectedSemester,
              items: _semesterList.map((s) => DropdownMenuItem(value: s, child: Text("Semester $s"))).toList(),
              onChanged: (v) => setState(() => _selectedSemester = v),
            ),
            const SizedBox(height: 12),

            TextField(controller: _telpController, keyboardType: TextInputType.phone, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "No. Telepon")),
            const SizedBox(height: 12),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Email",
                suffixText: "@gmail.com",
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Text('Jenis Kelamin:'),
                Radio(value: 'Pria', groupValue: _jenisKelamin, onChanged: (v) => setState(() => _jenisKelamin = v!)),
                const Text("Pria"),
                Radio(value: 'Perempuan', groupValue: _jenisKelamin, onChanged: (v) => setState(() => _jenisKelamin = v!)),
                const Text("Perempuan"),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addOrUpdateItem,
                    child: Text(_editingIndex == null ? "Submit" : "Update"),
                  ),
                ),
                if (_editingIndex != null)
                  TextButton(onPressed: _clearForm, child: const Text("Batal")),
              ],
            ),

            const Divider(height: 30),

            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text("Belum ada data"))
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return ListTile(
                          title: Text(item['nama']),
                          subtitle: Text("${item['npm']} • Semester ${item['semester']}"),
                          trailing: Text(item['kelas']),
                          onTap: () => _showDetail(item, index),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
