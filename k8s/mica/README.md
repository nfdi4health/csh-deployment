
# Install mica

`helm install my-test ./mica`

This creates a volume `{{ .Release.Name }}-template-container-mica` where one can store custom 
templates. Just copy the freemaker files into the running pod.

`kubcetl cp ~/PycharmProjects/mica-templates/. {{ .Release.Name }}-mongo-0:/usr/share/mica2/webapp/WEB-INF/classes/templates`


