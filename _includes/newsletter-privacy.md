{%- comment -%}
The newsletter section of a privacy policy, in Markdown: include it inside the policy's
"Registro de actividades de tratamiento de datos". Renders nothing while _data/newsletter.yml has
no `endpoint`, so the policy and the signup form appear together. Every site's policy carries it:
the form is on all of them and the list is one.
{%- endcomment -%}
{%- assign newsletter = site.data.newsletter -%}
{%- if newsletter.endpoint %}
## Tratamiento: Suscriptores de {{ newsletter.name }} {#newsletter}

Finalidad del tratamiento: enviar *{{ newsletter.name }}*, la newsletter de yeste.studio, a las
personas que se suscriben desde cualquiera de sus webs: cartas ocasionales con las novedades de
yeste.studio y de sus herramientas.

Base jurídica: tu consentimiento (artículo 6.1.a del RGPD), que das al suscribirte y confirmas desde
el correo que recibes a continuación. Puedes retirarlo en cualquier momento con el enlace de baja
que lleva cada envío o escribiendo al responsable. De acuerdo con el artículo 21 de la LSSI, no se
envía ninguna comunicación sin ese consentimiento previo.

Descripción de las categorías de suscriptores y de las categorías de datos personales:

- Suscriptores:
    - Personas que se suscriben a {{ newsletter.name }} desde una web de yeste.studio.
- Categorías de datos personales:
    - La dirección de correo electrónico.
    - La fecha y la dirección IP de la suscripción y de su confirmación, que acreditan el
    consentimiento, y la web y el lugar de la página desde los que te suscribes.
    {%- unless newsletter.tracking %}
    - Los envíos no miden aperturas ni clics.
    {%- endunless %}
- Las categorías de destinatarios a quienes se comunicaron o comunicarán los datos personales:
    - {{ newsletter.processor.name }} ({{ newsletter.processor.address }}), que gestiona la lista y
    los envíos como encargado del tratamiento. La transferencia internacional de datos está amparada
    por {{ newsletter.processor.transfer }}.
    [Política de privacidad de {{ newsletter.processor.name }}]({{ newsletter.processor.privacy }}).
- Plazos previstos para la supresión de las diferentes categorías de datos:
    - Mientras sigas suscrito. Al darte de baja dejas de recibir envíos, y puedes pedir además la
    supresión de tus datos.
{%- endif %}
