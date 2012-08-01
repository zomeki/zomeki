/*                                                       */
/* $Id: server.c,v 1.4 2009/02/13 02:02:47 sako Exp $                                                  */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#if defined(_WIN32) && !defined(__CYGWIN32__)
#include <windows.h>
#include <winsock.h>
#include <process.h>
#include <io.h>
#else
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#endif

#include "confpara.h"

int TmpMsg(char *, ...);
int ErrMsg(char *, ...);

typedef struct _GSOCKET *GSOCKET;
    
struct _GSOCKET {
    int fd;
    int child_fd;
    struct sockaddr_in addr;
    struct hostent *hp;

    fd_set readfds;
};

static int socket_destroy(GSOCKET sock)
{
    if (sock != NULL) {
	if (sock->child_fd != -1) {
#if defined(_WIN32) && !defined(__CYGWIN32__)
	    closesocket(sock->child_fd);
#else
	    close(sock->child_fd);
#endif
	}
	
#if defined(_WIN32) && !defined(__CYGWIN32__)
	closesocket(sock->fd);
#else
	close(sock->fd);
#endif
	
	free(sock);

#ifdef WIN32
	WSACleanup(); 
#endif
    }
    
    return 1;
}

static GSOCKET socket_create(int port)
{
    GSOCKET sock;
    
#ifdef WIN32
    {
	/* WinSockの初期化 */
	int		nResult;
	WORD	wRequireVersion;	/* 使用するWinSockのバージョン */
	WSADATA	lpWSAData;		/* WinSock初期化の結果 */
    
	/* WinSock2を使用するWinSockのバージョンとして設定 */
	wRequireVersion = MAKEWORD( 2, 0 );

	/* WinSockの初期化を行なう */
	nResult = WSAStartup( wRequireVersion, &lpWSAData );
	if( nResult != 0  )
	{
	    ErrMsg("WinSock initialize failed: %d\n", nResult);
	    return NULL;
	}

	/* 初期化したWinSockのバージョンが要求したものか確認 */
	if( lpWSAData.wVersion != wRequireVersion )
	{
	    ErrMsg("WinSock version mismatch: %d\n", nResult);
	    return NULL;
	}
    }
#endif

    sock = (GSOCKET)malloc(sizeof(struct _GSOCKET));
    if ((sock->fd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
	free(sock);
	return NULL;
    }
    
    memset((char *)&sock->addr, 0, sizeof(sock->addr));
    sock->child_fd = -1;

    sock->addr.sin_family = AF_INET;
    sock->addr.sin_addr.s_addr = INADDR_ANY;
    sock->addr.sin_port = htons( (unsigned short) port);
    
    if (bind(sock->fd, (struct sockaddr *)&sock->addr, sizeof(sock->addr)) == -1
	|| listen(sock->fd, 1) == -1) {
	socket_destroy(sock);
	return NULL;
    }
    
#if defined(_WIN32) && !defined(__CYGWIN32__)
    {
	u_long ulCmdArg;
	ulCmdArg = 1;
	ioctlsocket(sock->fd, FIONBIO, &ulCmdArg);
    }
#endif

    return sock;
}

static int socket_wait (GSOCKET sock)
{
    int n;
    
    FD_ZERO(&sock->readfds);

    FD_SET(sock->fd, &sock->readfds);
    if (sock->child_fd != -1) {
	FD_SET(sock->child_fd, &sock->readfds);
    }
	
    if ((n = select(FD_SETSIZE, &sock->readfds, NULL, NULL, NULL)) == -1) {
	return -1;
    }

    return 1;
}

static int socket_accept(GSOCKET sock)
{
    int len;
    int child_fd;
    
    if (FD_ISSET(sock->fd, &sock->readfds) != 0) {
	len = sizeof(sock->addr);
	if ((child_fd =
	     accept(sock->fd, (struct sockaddr *)&sock->addr, &len)) == -1) {
	    return -1;
	}
	    
	if (sock->child_fd == -1) {
	    sock->child_fd = child_fd;
	} else {
	    TmpMsg("Refuse connection.\n");
#if defined(_WIN32) && !defined(__CYGWIN32__)
	    closesocket(child_fd);
#else
	    close(child_fd);
#endif
	}
    }

    return 1;
}

static int socket_close_client(GSOCKET sock)
{
#if defined(_WIN32) && !defined(__CYGWIN32__)
    closesocket(sock->child_fd);
#else
    close(sock->child_fd);
#endif
    sock->child_fd = -1;

    return 1;
}

static int socket_read(GSOCKET sock, char *buf, int buf_size)
{
    int msglen;
    
    if (sock->child_fd == -1) return 0;
    
#if defined(_WIN32) && !defined(__CYGWIN32__)
    msglen = recv(sock->child_fd, buf, buf_size, 0);
#else
    msglen = read(sock->child_fd, buf, buf_size);
#endif

    return msglen;
}

static int socket_write(GSOCKET sock, char *buf, int buf_size)
{
    int msglen;

    if (sock->child_fd == -1) return 0;
    
#if defined(_WIN32) && !defined(__CYGWIN32__)
    msglen = send(sock->child_fd, buf, buf_size, 0);
#else
    msglen = write(sock->child_fd, buf, buf_size);
#endif

    return msglen;
}


static GSOCKET g_sock = NULL;
static char g_buf[8192];
static char *g_buf_ptr = NULL;
static int g_buf_offset = 0;

void refresh_server ( void )
{
    g_buf[0] = '\0';
    g_buf_ptr = NULL;
    g_buf_offset = 0;

    return;
}

int server_init ( int port )
{
    if (g_sock != NULL) socket_destroy(g_sock);
    
    if ((g_sock = socket_create(port)) == NULL) {
	return -1;
    }

    return 1;
}

void server_close_client ( void )
{
    if (g_sock != NULL) {
	socket_close_client (g_sock);
    }
    
    return;
}

int server_send ( char *message )
{
    int n;
    int nret = 0;
    
    if (g_sock != NULL) {
	int nsize;

	nsize = strlen(message);
	
	while (1) {
	    if ( nret >= nsize ) {
		break;
	    }
	    if ((n = socket_write( g_sock, message + nret, nsize - nret )) <= 0) {
		return -1;
	    }
	    nret += n;
	}
    }
    
    return nret;
}

int server_getline ( char *buf, int buf_size )
{
    int msglen = -1;
    char *p;

    if (g_sock == NULL) return -1;

    strcpy(buf, "");

    while (1) {
	if (g_buf_ptr == NULL) {
	    if (socket_wait(g_sock) <= 0) {
		ErrMsg("server_getline: wait error\n");
		return -1;
	    }

	    if (socket_accept(g_sock) <= 0) {
		ErrMsg("server_getline: accept failed\n");
		return -1;
	    }

	    if (g_buf_offset >= sizeof(g_buf) - 1) {
		g_buf_offset = 0;
	    } 

	    if ((msglen = socket_read(g_sock, g_buf + g_buf_offset, sizeof(g_buf) - g_buf_offset)) == -1) {
		continue;
	    } else if (msglen <= 0) {
		continue;
	    } else {
		g_buf[g_buf_offset + msglen] = '\0';
		g_buf_ptr = g_buf;
		g_buf_offset = 0;
	    }
	}

	if (g_buf_ptr != NULL) {
	    if ((p = strstr(g_buf_ptr, "./")) != NULL
		&& (p[2] == '\r' || p[2] == '\n')) {
		/* "./\n" was found */
		p[0] = '\n';
		p[1] = '\0';
		msglen = strlen(g_buf_ptr);
		strncpy(buf, g_buf_ptr, buf_size);

		if (p[2] == '\r' && p[3] == '\n') {
		    /* Windows newline "\r\n" was found */
		    p++;
		}
		
		if (p[3] == '\0') {
		    /* single line was included */
		    g_buf_ptr = NULL;
		} else {
		    /* multiple lines were included */
		    g_buf_ptr = p + 3;
		}
		g_buf_offset = 0;
		g_buf[0] = '\0';
		break;
	    } else {
		/* "./\n" was not found */
		msglen = 0;
		g_buf_offset = strlen(g_buf);
		if (g_buf_offset > 0 && g_buf[g_buf_offset - 1] == '\n') {
		    /* remove newline char */
		    if (g_buf_offset > 1 && g_buf[g_buf_offset - 2] == '\r') {
			g_buf_offset--;
		    }
		    g_buf[g_buf_offset - 1] = ' ';
		}
		g_buf_ptr = NULL;
	    }
	}
    }

    return msglen;
}

void server_destroy ( void )
{
    if (g_sock != NULL) {
	socket_destroy(g_sock);
	g_sock = NULL;
    }
    
    return;
}
