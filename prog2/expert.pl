/* Karett */
reptile(karret) :-
	ordnung(chelonia),
	ort(wasser),
	glieder(flossen).

/* Riesenschildkröte */
reptile(riesenschildkroete) :-
	ordnung(chelonia),
	not(glieder(flossen)).

/* Gavial */
reptile(gavial) :-
	ordnung(crocodilien),
	schnauze(schmall).

/* Krokodil */
reptile(krokodil) :-
	ordnung(crocodilien),
	vierter_uk(sichtbar).

/* Alligator */
reptile(alligator) :-
	ordnung(crocodilien),
	not(vierter_uk(sichtbar)).

reptile(blindschleiche) :-
	unterordnung(saurier),
	glieder(keine).

reptile(gecko) :-
	unterordnung(saurier),
	fuesse(haftpolzter).

glieder(beine) :-
	fuesse(X).

reptile(chamaeleon) :-
	unterordnung(saurier),
	fuesse(greifzangen).

reptile(eidechse) :-
	unterordnung(saurier),
	fuesse(krallen).

reptile(ringelnatter) :-
	unterordnung(saurier),
	ort(wasser),
	pupillen(rund).

reptile(aspisviper) :-
	unterordnung(schlangen),
	pupillen(gedehnt),
	kopfform(dreieckig).

ordnung(chelonia):- 
	rueckenpanzer(vorhanden).

ordnung(crocodilien) :-
	ort(wasser),
	schwanz(zusammengedrueckt).

ordnung(squamata) :-
	schwanz(zylindrisch).

ordnung(squamata) :- 
	unterordnung(saurier).

ordnung(squamata) :- 
	unterordnung(schlangen).

unterordnung(saurier) :-
	augenlider(sichtbar),
	not(glieder(keine)).
unterordnung(schlangen) :-
	not(augenlider(sichtbar)),
	glieder(keine).

/* ----------------- interaction ------------ */

:- dynamic known/3.
ask(A, V) :-
	known(yes, A, V), !.
ask(A, V) :-
	known(_, A, V), !, fail.

ask(A, V) :-
	write(A: V),
	write('? '),
	read(Y),
	asserta(known(Y, A, V)),
	Y == yes.

rueckenpanzer(X) :- ask(rueckenpanzer, X).
augenlider(X) :- ask(augenlider,X).
glieder(X) :- ask(glieder,X).
schnauze(X) :- ask(schnauze,X).
vierter_uk(X) :- ask(vierter_uk,X).
fuesse(X) :- ask(fuesse, X).
schwanz(X) :- ask(schwanz, X).
ort(X) :- ask(ort, X).
pupillen(X) :- ask(pupillen, X).

prolog :- 
	reptile(X), 
	write(X).
