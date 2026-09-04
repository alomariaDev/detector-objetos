FROM nginx:1.27-alpine

RUN wget -q \
	https://github.com/ultralytics/assets/releases/download/v8.4.0/yolo26n.onnx \
	-O /usr/share/nginx/html/yolo26n.onnx

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html