import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var location: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var alamatLengkap: String = "Mencari lokasi..."
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 1
        
        self.authorizationStatus = manager.authorizationStatus
        manager.requestWhenInUseAuthorization()
    }
     
    func requestLocation() {
        if CLLocationManager.locationServicesEnabled() {
            print("Memulai pelacakan satelit GPS...")
            manager.startUpdatingLocation()
        } else {
            print("GPS Perangkat Mati")
            DispatchQueue.main.async {
                self.alamatLengkap = "Fitur GPS Perangkat Mati"
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        
        DispatchQueue.main.async {
            self.location = latestLocation.coordinate
            
            // Cetak di konsol log untuk memastikan latitude sukses ditangkap
            print("🎯 LATITUDE SUKSES: \(latestLocation.coordinate.latitude)")
            print("🎯 LONGITUDE SUKSES: \(latestLocation.coordinate.longitude)")
            
            // Hentikan GPS agar hemat baterai setelah koordinat akurat didapat
            manager.stopUpdatingLocation()
            
            // Terjemahkan koordinat menjadi teks Kecamatan, Kota, Provinsi
            self.convertToAddress(from: latestLocation)
        }
    }
    
    // Pemutus Izin Lokasi Dinamis
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
                self.requestLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Gagal mendapatkan sinyal GPS: \(error.localizedDescription)")
    }
    
    // Fungsi konversi alamat ringkas
    private func convertToAddress(from clLocation: CLLocation) {
        geocoder.reverseGeocodeLocation(clLocation) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Geocoder Error: \(error.localizedDescription)")
                DispatchQueue.main.async { self.alamatLengkap = "Gagal memuat alamat GPS" }
                return
            }
            
            if let placemark = placemarks?.first {
                // 1. Ekstrak seluruh komponen layer wilayah dari satelit Apple Maps
                let subLocality = placemark.subLocality ?? ""          // Indikasi terkuat: Kecamatan/Kelurahan
                let locality = placemark.locality ?? ""                // Indikasi: Kota atau Kecamatan
                let subAdmin = placemark.subAdministrativeArea ?? ""   // Indikasi terkuat: Kota / Kabupaten Administrasi
                let admin = placemark.administrativeArea ?? ""         // Indikasi terkuat: Provinsi
                
                // 2. LOGIKA CERDAS PENYARINGAN KECAMATAN
                var kecamatanTerpilih = ""
                if !subLocality.isEmpty && subLocality != locality {
                    kecamatanTerpilih = subLocality
                } else if !locality.isEmpty && locality != subAdmin {
                    kecamatanTerpilih = locality
                }
                
                // 3. LOGIKA DETEKSI KOTA ATAU KABUPATEN (FALLBACK SINKRON)
                var kotaKabupatenTerpilih = ""
                if !subAdmin.isEmpty {
                    // Diutamakan jika subAdmin terisi (Sangat akurat untuk area Jabodetabek & DKI)
                    kotaKabupatenTerpilih = subAdmin
                } else if !locality.isEmpty && locality != kecamatanTerpilih {
                    // Fallback untuk daerah luar pulau/provinsi lain di mana Kota masuk ke field locality
                    kotaKabupatenTerpilih = locality
                }
                
                // 4. SUSUN ARRAY STRUKTUR WILAYAH SECARA BERTAHAP
                var bagianAlamat: [String] = []
                
                // Masukkan data Kecamatan yang sudah dibersihkan
                if !kecamatanTerpilih.isEmpty {
                    let cleanKec = kecamatanTerpilih.replacingOccurrences(of: "Kecamatan ", with: "")
                    bagianAlamat.append("\(cleanKec)")
                }
                
                // Masukkan data Kota/Kabupaten yang sudah dibersihkan
                if !kotaKabupatenTerpilih.isEmpty {
                    // Tambahkan standarisasi imbuhan kata "Kota" jika satelit hanya mengembalikan nama mentah (misal: "Bandung" -> "Kota Bandung")
                    var namaKotaClean = kotaKabupatenTerpilih
                    if !namaKotaClean.contains("Kabupaten") && !namaKotaClean.contains("Kota") && !namaKotaClean.contains("Jakarta") {
                        namaKotaClean = "\(namaKotaClean)"
                    }
                    bagianAlamat.append(namaKotaClean)
                }
                
                // Masukkan data Provinsi
                if !admin.isEmpty {
                    bagianAlamat.append(admin)
                }
                
                // Gabungkan array teks menggunakan pemisah tanda koma dan spasi
                let hasilAkhirTabel = bagianAlamat.joined(separator: ", ")
                
                // 5. Masukkan ke variabel utama di Main Thread
                DispatchQueue.main.async {
                    self.alamatLengkap = hasilAkhirTabel.isEmpty ? "Lokasi tidak terbaca" : hasilAkhirTabel
                    print("🎯 SUKSES STRUKTUR WILAYAH INDONESIA: \(self.alamatLengkap)")
                }
            }
        }
    }

}
