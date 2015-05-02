# encoding: utf-8
require "dxruby"

# 360度系の三角関数
def sin(deg);Math.sin(deg*Math::PI/180);end
def cos(deg);Math.cos(deg*Math::PI/180);end

# ２次元ベクトル
class Vec < Array
  attr_accessor :x,:y
  def initialize(x,y);@x,@y=x,y;end
  def self.[](x,y=nil)
    if y.nil? # 角度xの単位ベクトル
      Vec.new(cos(x),sin(x))
    else
      Vec.new(x,y)
    end
  end
  def +(o);Vec.new(@x+o.x,@y+o.y);end
  def -(o);Vec.new(@x-o.x,@y-o.y);end
  def /(o);@x/=o;@y/=o;self;end
  def *(o)
    case o
    when Vec
      @x*o.x+@y*o.y
    when Numeric
      @x*=o;@y*=o;self
    end
  end
  def rot(deg)
    @x,@y = cos(deg)*@x - sin(deg)*@y,sin(deg)*@x + cos(deg)*@y; self
  end
  def to_a;[@x,@y];end
end

# マウスの位置ベクトル
module Input
  def self.mouse_v
    Vec[Input.mouse_pos_x,Input.mouse_pos_y]
  end
end

# 鳥もどき
class Boid < Sprite
  attr_accessor :spd
  def initialize(x,y,angle,spd)
    super(x,y,new_image)
    self.angle,@spd = angle,spd
  end

  def new_image
    color = [rand(255),rand(255),rand(255)]
    img = Image.new(16,16)
    img.triangle_fill(0,4,16,8,0,12,color)
  end

  def update
    # 他のboid
    other = BOIDS.reject{|o|o.equal?(self)}

    # 衝突回避
    self.collision = [8,8,24]
    check(other).each do |near|

      # 相対位置
      dv = near.xy - xy

      # 離れるように方向転換
      if dv * right_v > 0
        self.angle -= 5
      else
        self.angle += 5
      end

      # 加速・減速
      if dv * front_v > 0
        self.spd += 1 if spd < 5
      else
        self.spd -= 1 if spd > 1
      end
    end
    self.collision = nil

    # 全体の中心
    dv = $center - xy

    # 中心に向かうように/離れるように方向転換
    d_angle = -5
    d_angle = 5 if dv * right_v > 0
    self.angle += d_angle

    # 中心に向かうように加速/減速
    if dv * front_v > 0
      self.spd += 1 if spd < 10
    else
      self.spd -= 1 if spd > 3
    end

    # マウス
    dv = Input.mouse_v - xy

    # マウスに向かうように/離れるように方向転換
    d_angle = -d_angle
    if Input.mouse_down?(M_RBUTTON)
      if dv * right_v > 0
        self.angle -= 5
      else
        self.angle += 5
      end
    end

    # 移動
    self.xy += front_v * @spd
    vanish unless in_frame?
  end

  # 画面外で消去
  def in_frame?
    x.between?(-32,Window.width) && y.between?(-32,Window.height)
  end

  # 位置ベクトル
  def xy;Vec[x,y];end
  def xy=(o);self.x=o.x;self.y=o.y;end

  # 方向ベクトル
  def front_v;Vec[angle];end
  def right_v;Vec[angle+90];end
end


font = Font.new(24)
BOIDS = []
$center = nil

Window.loop do
  Window.draw_font(20,5,sprintf("number of fish: %d",BOIDS.size),font)

  if Input.mouse_down?(M_LBUTTON)
    BOIDS << Boid.new(Input.mouse_pos_x,Input.mouse_pos_y,rand(360),5) # if BOIDS.size < 10
  end

  all_boid = BOIDS.map(&:xy)
  unless all_boid.empty?
    $center = all_boid.inject{|a,b|a+=b} / all_boid.size
  end

  Sprite.update BOIDS
  Sprite.clean BOIDS
  Sprite.draw BOIDS
end
