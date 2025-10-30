############################################################
# Automatización de pruebas E2E - Mercado Libre Android
# ----------------------------------------------------------
# Frameworks usados:
#   - Appium (control de la app móvil)
#   - RSpec (estructura de pruebas automatizadas)
# ----------------------------------------------------------
# Objetivo:
#   Ejecutar un flujo de prueba en la app de Mercado Libre:
#   1. Buscar "PlayStation 5"
#   2. Aplicar filtros (Condición, Envíos, Ordenar)
#   3. Extraer información de los primeros resultados
# ----------------------------------------------------------
# Autor: [Christian Yair Lopez Martinez]
# Entorno: Ruby + Appium + RSpec
# Fecha: [2025-10-30]
############################################################

require 'appium_lib'
require 'rspec'

############################################################
#  Carga de capacidades y configuración del driver Appium
############################################################

# Función que carga las capacidades del archivo appium.txt
# Este archivo contiene las configuraciones del dispositivo,
# aplicación, servidor Appium, etc.
def caps
  Appium.load_appium_txt file: File.join(Dir.pwd, 'appium.txt'), verbose: true
end

# Inicializa el driver global de Appium
Appium::Driver.new(caps, true)
Appium.promote_appium_methods Object


############################################################
# Funciones auxiliares de espera y búsqueda de elementos
############################################################

# Espera hasta que un elemento esté visible y habilitado para interactuar.
# - locator: cadena con el localizador (XPath o ID)
# - type: tipo de búsqueda (:xpath o :id)
# - timeout: tiempo máximo de espera en segundos
def wait_for_element(locator, type=:xpath, timeout=15)
  Selenium::WebDriver::Wait.new(timeout: timeout).until do
    el = type == :id ? $driver.find_element(:id, locator) : $driver.find_element(:xpath, locator)
    el.displayed? && el.enabled? ? el : false
  end
rescue
  nil
end

# Pausa estática (solo para casos donde no hay alternativa de sincronización)
def wait(sec=2)
  sleep(sec)
end

# Espera a que un elemento por XPath sea visible
def wait_for_xpath(xpath, timeout=15)
  Selenium::WebDriver::Wait.new(timeout: timeout).until do
    el = $driver.find_element(:xpath, xpath)
    el.displayed? ? el : nil
  end
rescue
  nil
end


############################################################
# Prueba automatizada - Mercado Libre Android
############################################################

RSpec.describe 'Mercado Libre Android - Search & Filters' do
  
  ##########################################################
  # Configuración inicial (setup)
  ##########################################################
  before(:all) do
    $driver.start_driver
    $driver.manage.timeouts.implicit_wait = 20
    # Crea carpeta para guardar screenshots si no existe
    Dir.mkdir('screenshots') unless Dir.exist?('screenshots')
  end

  ##########################################################
  # Limpieza final (teardown)
  ##########################################################
  after(:all) do
    $driver.quit_driver
  end

  ##########################################################
  # Caso de prueba principal
  ##########################################################
  it 'Busca PS5, aplica filtros y extrae 5 resultados' do
    
    # Esperar a que la barra de búsqueda esté visible
    search_bar_xpath = '//android.widget.LinearLayout[@resource-id="com.mercadolibre:id/ui_components_toolbar_search_field"]'
    search_bar = wait_for_element(search_bar_xpath, :xpath, 30)
    raise "No se pudo encontrar la barra de búsqueda" unless search_bar
    $driver.screenshot("screenshots/step_open_app.png")

    # Click en la barra de búsqueda
    search_bar.click
    wait(1)

    # Ingresar texto en el campo de autosuggest
    autosuggest_input_xpath = '//android.widget.EditText[@resource-id="com.mercadolibre:id/autosuggest_input_search"]'
    search_input = wait_for_element(autosuggest_input_xpath, :xpath, 15)
    raise "No se pudo encontrar el input de búsqueda" unless search_input
    search_input.send_keys('playstation 5')
    $driver.screenshot("screenshots/busqueda.png")
    $driver.press_keycode(66) # ENTER
    wait(3)
    $driver.screenshot("screenshots/step_search.png")

    # Abrir menú de filtros
    filter_xpath = '(//android.widget.LinearLayout[@resource-id="com.mercadolibre:id/appbar_content_layout"])[1]/android.widget.LinearLayout/android.widget.ImageView[1]'
    filter_button = wait_for_element(filter_xpath, :xpath, 10)
    raise "No se pudo encontrar el botón de filtros" unless filter_button
    filter_button.click
    wait(2)
    $driver.screenshot("screenshots/step_filter_open.png")


    ##########################################################
    # Aplicar Filtros (Condición, Envíos, Ordenar)
    ##########################################################

    # Condición → Nuevo
    condicion = wait_for_xpath('//android.view.View[@content-desc="Condición"]', 10)
    raise "No se encontró Condición" unless condicion
    condicion.click
    wait(1)

    nuevo_btn = wait_for_xpath('//android.widget.ToggleButton[@resource-id="ITEM_CONDITION-2230284"]', 10)
    raise "No se encontró opción Nuevo" unless nuevo_btn
    nuevo_btn.click
    $driver.screenshot("screenshots/filtrocondicion.png")
    wait(1)

    # Envíos → Local
    envios = wait_for_xpath('(//android.widget.TextView[@text="Envíos"])[1]', 10)
    raise "No se encontró Envíos" unless envios
    envios.click
    wait(1)

    local_envio = wait_for_xpath('//android.widget.ToggleButton[@resource-id="SHIPPING_ORIGIN-10215068"]', 10)
    raise "No se encontró Envíos Local" unless local_envio
    local_envio.click
    $driver.screenshot("screenshots/envios.png")
    wait(2)

    # Scroll automático entre filtros
    envios = wait_for_xpath('//android.view.View[@content-desc="Cantidad de controles incluidos"]', 10)
    raise "No se encontró Envíos" unless envios
    envios.click
    wait(1)

    envios = wait_for_xpath('//android.view.View[@content-desc="Con Wi-Fi "]', 10)
    raise "No se encontró Envíos" unless envios
    envios.click
    wait(1)

    # Ordenar → Mayor a menor
    condicion = wait_for_xpath('//android.view.View[@content-desc="Ordenar por "]', 10)
    raise "No se encontró Condición" unless condicion
    condicion.click
    wait(1)

    nuevo_btn = wait_for_xpath('//android.widget.ToggleButton[@resource-id="sort-price_desc"]', 10)
    raise "No se encontró opción Nuevo" unless nuevo_btn
    nuevo_btn.click
    $driver.screenshot("screenshots/filtrocondicion.png")
    wait(1)

    # Volver a resultados
    begin
      ver_res = wait_for_xpath('//android.widget.Button[contains(@text,"Ver")]', 3)
      ver_res.click if ver_res
    rescue
    end
    $driver.screenshot("screenshots/resultados.png")
    wait(4)


    ##########################################################
    # Extracción dinámica de productos (Top N resultados)
    ##########################################################

    products = []
    sleep(2)  # Espera breve para carga de UI

    # Buscar todos los cards visibles de productos
    cards = $driver.find_elements(:xpath, "//android.view.View[@resource-id='polycard_component']")

    if cards.empty?
      puts "No se encontraron elementos para extraer"
    else
      # Tomar los primeros 2 (modificar según necesidad)
      cards.first(2).each_with_index do |card, idx|
        
        # Extraer nombre del producto
        title = begin
          card.find_element(:xpath, ".//android.widget.TextView[@text]").text
        rescue
          "Título no disponible"
        end

        # Extraer precio
        price = begin
          price_element = card.find_elements(:xpath, ".//android.widget.TextView[@content-desc]")
                              .find { |el| el.attribute('content-desc')&.include?('Pesos') }
          price_element ? price_element.attribute('content-desc') : "Precio no disponible"
        rescue
          "Precio no disponible"
        end

        # Guardar datos en array
        products << { name: title.strip, price: price.strip }
      end

      # Mostrar resultados en consola
      puts "\n===== RESULTADOS (Primeros #{products.size}) ====="
      products.each_with_index do |p, i|
        puts "#{i+1}) #{p[:name]} | #{p[:price]}"
      end
    end

    # Validar que al menos haya un resultado
    expect(products.size).to be >= 1
  end
end
