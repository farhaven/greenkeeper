; Moisture sensor:
; - https://www.adafruit.com/products/1298?PageSpeed=noscript

(import
  json
  time
  [flask [Flask Response]]
  [HyREPL.server [start-server]]
  [HyREPL.middleware.eval :as repl])

(setv repl.eval-module (globals))
(def app (Flask --name--))

(defn get-plant-data [&optional [name ""]]
  ; TODO: - look up plant data in Redis database
  ;       - plot fancy moisture/light level graphs (with CSS/JS?)
  {'moisture {'raw 0.2
              'state 'CRIT} ; one of 'CRIT 'LOW 'OK 'TOOMUCH
   'type 'Ficus
   'temperature 10.3 ; degrees celsius
   'light 0.7
   'name name})

(defn render-plant [name]
  (let [[r (Response :headers {"Content-Type" "application/json"})]]
    (.set-data r (json.dumps (get-plant-data name)))
    r))

(defn render-index []
  (+ "<?doctype html>"
     "<html><head></head>"
     "<body><ul>"
     "<li><a href=\"/plant\">/plant</a></li>"
     "<li><a href=\"/plant/Bob\">/plant/Bob</a></li>"
     "</ul></body></html>"))

(with-decorator
  (.route app "/plant" :methods ["GET"] :defaults {'name "Fred"})
  (.route app "/plant/<name>" :methods ["GET"])
  (fn [name]
    (render-plant name)))


(with-decorator
  (.route app "/" :methods ["GET"])
  (fn []
    (render-index)))

(defmain [&rest args]
  (let [[s (start-server :port 4000)]]
    (print (.format "REPL listening on {}" (. (second s) server-address)))
    (.run app)))
