// 1) Belum Bisa Membuat Value Dropdown Berubah
// 2) Belum Bisa Menampilkan ListView untuk Jenis Peminjaman

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

class JenisPinjamanModel {
  String id;
  String nama;
  JenisPinjamanModel({required this.id, required this.nama});
}

class DetilJenisPinjamanModel {
  String id;
  String nama;
  String bunga;
  String is_syariah;
  DetilJenisPinjamanModel(
      {required this.id,
      required this.nama,
      required this.bunga,
      required this.is_syariah});
}

class JenisPinjamanCubit extends Cubit<JenisPinjamanModel> {
  String selected_id = "";
  JenisPinjamanCubit() : super(JenisPinjamanModel(id: "", nama: ""));
  List<JenisPinjamanModel> list = <JenisPinjamanModel>[];

  //map dari json ke atribut
  void setFromJson(Map<String, dynamic> json) {
    var data = json["data"];
    for (var key in data) {
      String id = data['id'];
      String nama = data['nama'];
      print(id + " " + nama);
      emit((JenisPinjamanModel(id: id, nama: nama)));
    }

    //emit state baru, ini berbeda dgn provider!
  }

  void fetchData(String id) async {
    String url = "http://178.128.17.76:8000/jenis_pinjaman/" + id;
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}

class DetilJenisPinjamanCubit extends Cubit<DetilJenisPinjamanModel> {
  String selected_id_detil = "";

  DetilJenisPinjamanCubit()
      : super(DetilJenisPinjamanModel(
            id: "", nama: "", bunga: "", is_syariah: ""));

  void setFromJson(Map<String, dynamic> json) {
    String id = json['id'];
    String nama = json['nama'];
    String bunga = json['bunga'];
    String is_syariah = json['is_syariah'];

    emit(DetilJenisPinjamanModel(
        id: id, nama: nama, bunga: bunga, is_syariah: is_syariah));
  }

  void fetchData(String id) async {
    String url = "http://178.128.17.76:8000/detil_jenis_pinjaman/" + id;
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<JenisPinjamanCubit>(
          create: (context) => JenisPinjamanCubit(),
        ),
        BlocProvider<DetilJenisPinjamanCubit>(
          create: (context) => DetilJenisPinjamanCubit(),
        ),
        // Tambahkan BlocProvider lain jika diperlukan
      ],
      child: MaterialApp(
        title: 'My App P2P',
        home: HomePage(),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          children: [
            BlocBuilder<DetilJenisPinjamanCubit, DetilJenisPinjamanModel>(
                builder: (context, detil) {
              return Center(
                  child: Column(
                children: [
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {},
                    child: Card(
                      margin: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "ID : ${detil.id}",
                          ),
                          Text("Nama : ${detil.nama}"),
                          Text("Bunga : ${detil.bunga}%"),
                          Text("Syariah : ${detil.is_syariah}"),
                        ],
                      ),
                    ),
                  ),
                ],
              ));
            }),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var selectedPinjaman = "1";

    List<DropdownMenuItem<String>> jenis_pinjaman = [];
    var itm1 = const DropdownMenuItem<String>(
      value: "1",
      child: Text("Jenis pinjaman 1"),
    );

    var itm2 = const DropdownMenuItem<String>(
      value: "2",
      child: Text("Jenis pinjaman 2"),
    );

    var itm3 = const DropdownMenuItem<String>(
      value: "3",
      child: Text("Jenis pinjaman 3"),
    );

    jenis_pinjaman.add(itm1);
    jenis_pinjaman.add(itm2);
    jenis_pinjaman.add(itm3);

    return Scaffold(
      appBar: AppBar(
        title: Text('My App P2P'),
      ),
      body: Center(
        child: Column(
          children: [
            Column(
              children: [
                BlocBuilder<JenisPinjamanCubit, JenisPinjamanModel>(
                    builder: (context, pinjaman) {
                  return Center(
                      child: Column(
                    children: [
                      Text(
                          "2100192, Muhammad Rayhan Nur ; 2103727, Cantika Putri Arbiliansyah; Saya berjanji tidak akan berbuat curang data atau membantu orang lain berbuat curang"),
                      DropdownButton(
                          value: selectedPinjaman,
                          items: jenis_pinjaman,
                          onChanged: (String? item) {}),
                      SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          context
                              .read<DetilJenisPinjamanCubit>()
                              .fetchData(selectedPinjaman);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const SecondPage(title: 'Detil');
                          }));
                        },
                        child: Card(
                          margin: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: Image.network(
                                    'https://3.bp.blogspot.com/-J9Q2f6Vhk9A/WAfhXv9NdaI/AAAAAAAACOg/9T0ojQZ4ySUtE78rSdJOZ5BcCJkXELdwQCLcB/s1600/0_90524_c7d1f7aa_orig.png'),
                                title: Text(pinjaman.nama),
                                subtitle: Text('ID : ${pinjaman.id}'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
