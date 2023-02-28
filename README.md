# Taquin

Dépendant de la version de Delphi, plusieurs versions différentes autour du même jeu. Avec Delphi 10.4.2 Sydney utilisation du [nouveau composant VCL TControlList](https://docwiki.embarcadero.com/RADStudio/en/Using_VCL_TControlList_Control).

L'objectif principal était dans un premier temps une utilisation du nouveau composant TControlList de la version 10.4.2 de Delphi.

![Capture](https://user-images.githubusercontent.com/51124639/118252690-54cb1480-b4a9-11eb-9704-0243e2358521.PNG)

L'idée de ce dépôt, downgrader cette première version pour répondre à la question "Comment faire si je n'ai pas la version 10.4.2 ?"

La réponse principale est : "Remplacer TControlList par un TScrollBox et un TFrame" mais chaque version à apporté ses nouveautés.

* 10.3 à 10.4.2 Utilisation de TImageCollection
* de D2009 à 10_2 Utilisation des ressources (TImageCollection inexistant)
* version FMX

![Capture](https://user-images.githubusercontent.com/51124639/119260606-d9b5dc80-bbd3-11eb-8ebc-ba03f2db408d.PNG)

Cirec m'a permis de proposer sa version (taquin_7_0) qui serait portable à partir de la version versions D6.
Améliorée d'un mélange assurant la faisabilité du puzzle.

Patrick Prémartin s'est lui lancé dans l'aventure FMX avec [Taquin DX Books](https://github.com/DeveloppeurPascal/TaquinDXBooks).

Pour tout savoir sur le composant TControlList, regardez ma "[plongée dans le TControlList de Delphi](https://serialstreameur.fr/webinaire-20210520.php)" et suivez les liens ou consultez [mes exemples](https://github.com/Serge-Girard/TControlList).
