import io, yaml, os, os.path

class Creds(object):        
    DEFAULT_CREDS_LIST = ([] if os.environ.get('USER') is None else ['creds.'+os.environ.get('USER','user')+'.yaml']) +\
                         ['creds.debug.yaml','creds.yaml']
    SOURCE = next(i for i in (os.environ.get('CREDS_YAML'),DEFAULT_CREDS_LIST) if i is not None )
    __slots__ = ('_opt','_SOURCE')

    def __getattribute__(self, name):
        o = super().__getattribute__('_opt')
        if name not in ('_opt','dicto','get','get_bool','__getattribute__','_SOURCE') \
                and o is not None \
                and name in o:
            return o[name]
        return super().__getattribute__(name)

    def __init__(self, _SOURCE=None, **kw):
        self._SOURCE = os.path.abspath(_SOURCE) if _SOURCE is not None else None
        self._opt = kw

    def dicto(self):
        return self._opt

    def get(self, name, dflt=None):
        return self._opt.get(name, dflt)        
    
    def get_bool(self, name):
        return not not self._opt.get(name,None)

    @classmethod
    def assign(cls, source):
        cls.SOURCE = source
    
    @classmethod
    def source(cls, creds_filename=None):
        if creds_filename is None:
            if type(cls.SOURCE) is str:
                creds_filename = cls.SOURCE
            elif type(cls.SOURCE) in (list,tuple):
                for s in cls.SOURCE:
                    if os.path.exists(s):
                        creds_filename = s
                        break
            if creds_filename is None:
                creds_filename = 'creds.yaml'
        return creds_filename

    @classmethod
    def stream(cls, source=None, acces='r'):
        if source is None:
            source = cls.source()
        if not os.path.exists(source) and acces=='r':
            return io.StringIO('\n')
        else:
            return open(source, acces)        
        
    
    @classmethod
    def load(cls, scope, source=None):
        _SOURCE = cls.source(source)
        with cls.stream(_SOURCE) as f:
            d = yaml.load(f)
            if d is None: d = {}
            d = d.get(scope,{})
            return Creds( _SOURCE=_SOURCE, **d )
        
    def store(self, scope, source=None):        
        d = {}
        with self.stream(self.source(source)) as f:
            d = yaml.load(f)
            if d is None: d = {}
            d[scope] = self._opt
        with self.stream(self.source(source), 'w+') as f:
            yaml.dump(d, f, default_flow_style=False)

    def setenv(self, opt, env):
        o = self.get(opt)
        if o is not None:
            os.environ[env] = o
        return self

if __name__ == '__main__':
    c = Creds(user='user',password='password')
    assert c.user == 'user'
    assert c.password == 'password'
    S = '''
a:
    user: user
    password: "password"
b:
    url: http://abc
    secrete: "aha"
'''
    with open('t.yaml','w+') as f:
        f.write(S)
    b = Creds.load('b',source='t.yaml')
    assert b.url == 'http://abc'
    assert b.secrete == 'aha'

