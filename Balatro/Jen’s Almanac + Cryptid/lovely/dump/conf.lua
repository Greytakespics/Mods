LOVELY_INTEGRITY = 'cd11f803e89c48e476527cbfeec15ed491f002735c8b21fdbb0b2939cfd96518'

_RELEASE_MODE = false
_DEMO = false

function love.conf(t)
	t.console = not _RELEASE_MODE
	t.title = 'Balatro'
	t.window.width = 0
    t.window.height = 0
	t.window.minwidth = 100
	t.window.minheight = 100
end 
