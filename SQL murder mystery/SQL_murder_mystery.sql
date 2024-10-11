/* Debemos ayudar a la policía a encontrar a un asesino buscando pistas en una base de datos.

Puedes encontrar la base de datos y el enunciado inicial en http://mystery.knightlab.com/

Las pistas que nos dan son: 
- Fue un asesinato (murder) 
- Cometido en SQL City (SQL City)
- En algún momento del 15 de enero de 2018 (20180115)

Con estas pistas podemos sacar el informe policial de la escena del crimen
*/

SELECT * FROM crime_scene_report
WHERE city = "SQL City" 
 AND type = "murder"
 AND date = "20180115";
 
/*
 
En la columna description pone:
 
"Security footage shows that there were 2 witnesses. 
 The first witness lives at the last house on "Northwestern Dr". 
 The second witness, named Annabel, lives somewhere on "Franklin Ave"
 
Es decir, existen 2 testigos:
 
Testigo 1: vive en la última casa de "Northwestern Dr"
Testigo 2: Se llama Annabel y vive en alguna parte de "Franklin Ave"

Necesitamos encontrar a estas dos personas y ver sus declaraciones.


 */
  
 SELECT * FROM person
 WHERE address_street_name LIKE "Northwestern DR"
 ORDER BY address_number DESC;
 
/* Hemos ordenado los resultados de la consulta de forma que tengamos la última casa de Northwestern DR (la casa 
de nuestro testigo) en la primera fila

Testigo 1:
 - name = Morty Schapiro
 - id = 14887
 */
 

 SELECT * FROM person
 WHERE address_street_name = "Franklin Ave"
 AND name LIKE "%annabel%";
 
 /* 
 Testigo 2:
  - name = Annabel Miller
  - id = 16371
 
Con sus identificaciones podemos ver sus declaraciones 
*/

 SELECT * FROM interview
 WHERE person_id = 14887
  OR person_id = 16371;
 
 
 /* 
Declaración del Sr. Schapiro:
 
 "I heard a gunshot and then saw a man run out. 
  He had a "Get Fit Now Gym" bag. 
  The membership number on the bag started with "48Z". 
  Only gold members have those bags. 
  The man got into a car with a plate that included "H42W"."
  
Es un hombre, con una bolsa de un gimnasio llamado Get Fit Now Gym que solo reciben
los miembros de clase Gold. Su nº de socio empezaba en 48Z. Este testigo también vio al sospechoso
entrar en un coche y pudo detectar H42W en su matrícula
 
Declaración de la Sra Miller:
 
 "I saw the murder happen, and 
  I recognized the killer from my gym when I was working out 
  last week on January the 9th."
 
La Sra. Miller vio el crimen y aseguró haber visto al asesino la semana pasada (9 de enero) en el mismo
gimnasio al que la testigo asiste.
  
*/ 
 
SELECT * FROM get_fit_now_member
JOIN person ON get_fit_now_member.person_id = person.id
JOIN drivers_license ON person.license_id = drivers_license.id
WHERE get_fit_now_member.id LIKE "48z%"
 AND membership_status = "gold";

/* Hemos unido la información de 3 tablas para sacar coincidencias y vemos que el principal sospechoso
es:

 - Jeremy Bowers con id = 67318
 
 En la tabla tenemos también la información sobre su coche y coincide con lo aportado por Schapiro
 
 Para asegurarnos que es el asesino vamos a comprobar su check in para ver si coincide con el 
 testimonio de Annabel (debió estar en el gimnasio el 9 de enero)
 
 */
 
 SELECT * FROM get_fit_now_check_in
 WHERE membership_id = "48Z55";
  
 /* En efecto, el sospechoso estuvo 1 hora y media en el gimnasio el 9 de enero.
 
 El asesino es Jeremy Bowers
 
 */
     
INSERT INTO solution VALUES (1, 'Jeremy Bowers');
        SELECT value FROM solution;
		
/*

Es correcto. Pero parece que hay más...

"Congrats, you found the murderer! 
But wait, there's more... If you think you're up for a challenge, 
try querying the interview transcript of the murderer to find the real villain behind this crime. 
If you feel especially confident in your SQL skills, try to complete this final step 
with no more than 2 queries. 
Use this same INSERT statement with your new suspect to check your answer."

Parece que debemos comprobar la declaración del sospechoso para encontrar a la verdadera mente criminal de 
esta historia.
 */
 
 SELECT * FROM interview
 WHERE person_id = 67318;
 
 
 /*
 
 El presunto asesino dice:
 
"I was hired by a woman with a lot of money. 
  I don't know her name but I know she's around 5'5" (65") or 5'7" (67"). 
  She has red hair and she drives a Tesla Model S. 
  I know that she attended the SQL Symphony Concert 3 times in December 2017."
  
Al parecer fue contratado por una mujer adinerada. No preguntó su nombre, pero mide entre 65" y 67", es pelirroja 
y conduce un Tesla Model S. También dice que la mujer asistió 3 veces al SQL Symphony Concert
en diciembre de 2017.
  
Dado que la mayoría de pistas vienen de la tabla drivers_license, vamos a usa JOIN para unir esa tabla con 
person y facebook_event_checkin
 
*/ 
 
SELECT * FROM drivers_license
JOIN person ON drivers_license.id = person.license_id
JOIN facebook_event_checkin ON facebook_event_checkin.person_id = person.id
WHERE drivers_license.car_make = "Tesla"
  AND drivers_license.car_model = "Model S"
  AND drivers_license.hair_color = "red"
  AND drivers_license.gender = "female";
 
 
/* Tenemos una coincidencia. La sospechosa es Miranda Priestly que asistió 3 veces al SQL Symphony Concert 
y su altura coincide con el rango dado por el asesino.

Solo falta comprobar sus ingresos para ver si es adinerada:
 
*/
 
 SELECT * FROM income
 WHERE ssn = 987756388;
 
/* La sospechosa tiene unos ingresos de 310000.

La sospechosa de haber orquestado el asesinato es Miranda Priestly.

Comprobamos

*/


 INSERT INTO solution VALUES (1, 'Miranda Priestly');
        SELECT value FROM solution;
		

/*
		
"Congrats, you found the brains behind the murder! 
  Everyone in SQL City hails you as the greatest SQL detective of all time. 
  Time to break out the champagne!"
  
Es correcto.

*/
