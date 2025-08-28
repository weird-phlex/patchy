module Components::FormsHelper
  def render_form_with(**opts, &block)
    form_with(**opts, builder: Shadcn::FormBuilder, &block)
  end

  def render_form_for(obj, **opts, &block)
    form_for(obj, **opts, builder: Shadcn::FormBuilder, html: opts, &block)
  end
end
