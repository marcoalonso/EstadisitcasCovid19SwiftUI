//
//  ContentView.swift
//  Covid19 Estadisticas
//
//  Created by marco alonso on 07/12/20.
//

import SwiftUI

struct Country: Codable {
    public var country: String
    public var updated: Double
    public var cases: Double
    public var active: Double
    public var recovered: Double
    public var countryInfo: CountryInfo
}

struct CountryInfo: Codable {
    public var _id: Int
    public var iso2: String
    public var iso3: String
    public var lat: Int
    public var long: Int
    public var flag: String
}

public class getData: ObservableObject {
    @Published var data: Country!
    
    init(pais: String) {
        actualizarDatos(pais: pais)
    }
    
    func actualizarDatos(pais: String){
        let url = "https://corona.lmao.ninja/v3/covid-19/countries/\(pais)"
        let session = URLSession(configuration: .default)
        session.dataTask(with: URL(string: url)!) { ( data, respuesta, error) in
            if error != nil {
                
                print(error?.localizedDescription ?? "Error al obtener datos")
                return
            }
            do {
                let json = try JSONDecoder().decode(Country.self, from: data!)
                
                DispatchQueue.main.async {
                    self.data = json
                }
                
            } catch let error {
                print(error.localizedDescription)
            }
        }.resume()
    }
}

func obtenerValor(data: Double) -> String {
    let formato = NumberFormatter()
    formato.numberStyle = .decimal
    
    return formato.string(from: NSNumber(value: data))!
}

func obtenerImagen(imagenString: String) -> UIImage {
    let imagenURL = URL(string: imagenString)
    let imagenData = try! Data(contentsOf: imagenURL!)
    let imagen = UIImage(data: imagenData)
    return imagen!
}




struct Indicator: UIViewRepresentable {

    func makeUIView(context: UIViewRepresentableContext<Indicator>) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .large)
        view.startAnimating()
        return view
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Indicator>) {
        
    }
}

struct ContentView: View {
   //creamos una instancia de la clase getData :)
    @ObservedObject var data = getData(pais: "mexico")
    
    @State var pais: String = "mexico"
    
    var body: some View {
        ZStack {
            if self.data.data != nil {
                VStack(alignment: .center) {
                    Text("Covid-19 Virus APP")
                        .font(.system(size: 30))
                        .bold()
                    HStack{
                        TextField("Ingresa el nombre de 1 pais...", text: $pais)
                            .padding(10)
                            .font(Font.system(size: 15, weight: .medium, design: .serif))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                        Button(action: {
                            self.data.actualizarDatos(pais: self.pais)
                        }) {
                            Text("Buscar")
                        }
                    }.frame(width: 250).padding()
                    Image(uiImage: obtenerImagen(imagenString: data.data.countryInfo.flag))
                        .resizable()
                        .frame(width: 250, height: 125, alignment: .center)
                    Text("Total de casos : \(obtenerValor(data: self.data.data.cases))")
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(width: 200, height: 175, alignment: .center)
                        .multilineTextAlignment(.center)
                    Text("Casos positivos: \(obtenerValor(data: self.data.data.active))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(width: 200, height: 50, alignment: .center)
                        .background(Color.red)
                        .padding(20)
                    Text("Recuperados: \(obtenerValor(data: self.data.data.recovered))")
                        .font(.headline)
                        .frame(width: 200, height: 50, alignment: .center)
                        .background(Color.green)
                    }
            } else {
                GeometryReader { geo in
                    VStack {
                        Indicator()
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
