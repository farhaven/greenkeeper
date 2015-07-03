; Moisture sensor:
; - https://www.adafruit.com/products/1298?PageSpeed=noscript

(import
  json
  time
  logging
  jinja2
  os
  [flask [Flask Response send-from-directory]]
  [HyREPL.server [start-server]]
  [HyREPL.middleware.eval :as repl])

(setv repl.eval-module (globals))
(def stream-handler (logging.StreamHandler))
(.setLevel stream-handler logging.WARNING)

(def app (Flask --name-- :static-url-path ""))
(.addHandler (. app logger) stream-handler)


(defn get-plant-data [&optional [name ""]]
  ; TODO: - look up plant data in Redis database
  ;       - plot fancy moisture/light level graphs (with CSS/JS?)
  {'moisture {'raw 0.2
              'state 'crit} ; one of 'crit 'low 'ok 'toomuch
   'type 'Ficus
   'temperature {'raw 20.3 ; degrees celsius
                 'state 'ok} ; same as for moisture
   'light 0.7
   'name name})

(defn render-plant [name]
  (let [[r (Response :headers {"Content-Type" "application/json"})]]
    (.set-data r (json.dumps (get-plant-data name) :indent 2))
    r))

(with-decorator
  (.route app "/plant/<name>" :methods ["GET"])
  (fn [name]
    (render-plant name)))


(defn get-plants []
  {'plants
   (dict-comp
     n
     (get-plant-data n)
     [n ["Bob" "Fred"]])
   'tstamp 1})

(defn render-plants []
  (let [[r (Response :headers {"Content-Type" "application/json"})]]
    (.set-data r (json.dumps (get-plants) :indent 2))
    r))

(with-decorator
  (.route app "/plants")
  (fn []
    (render-plants)))

(with-decorator
  (.route app "/s/<path:path>")
  (fn [path]
    (send-from-directory (os.path.join (os.getcwd) "static") path)))


(def templates {})

(defn render-template [name &kwargs kw]
  (unless (in name templates)
    (let [[txt (with [[f (open (os.path.join "templates" name))]] (.read f))]
          [templ (jinja2.Template txt)]]
      (assoc templates name templ)))
  (apply (. (get templates name) render) [] kw))

(defn render-index []
  (render-template "index.html"))

(with-decorator
  (.route app "/" :methods ["GET"])
  (fn []
    (render-index)))


(defmain [&rest args]
  (let [[s (start-server :port 4000)]]
    (print (.format "REPL listening on {}" (. (second s) server-address)))
    (.run app)))
