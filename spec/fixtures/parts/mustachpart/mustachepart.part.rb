part :mustachepart do
  title "Mustache part"
  description "A part that has a template that is exposed to client scripts"
  action do
    mustache :mustachetemplate, :locals => {:mustache => "data"}
  end
end