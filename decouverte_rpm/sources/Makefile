hello_in_c:
	gcc -g -o hello_in_c hello_in_c.c

clean:
	rm hello_in_c

install:
	mkdir -p $(DESTDIR)/usr/bin
	install -m 0755 hello_in_c $(DESTDIR)/usr/bin/hello_in_c
