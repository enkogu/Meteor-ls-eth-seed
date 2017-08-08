@table-controls-component =-> tr th colspan:\10, link-panel!

link-panel=->
    count = +Meteor.users.find!count!
    current-page  = +address-last!
    left-chevron  = ''
    right-chevron = ''
    if count < 0 => return null

    pages = ceiling count/10

    link-arr = []

    if pages <= 9 # просто отрисовываем все цифры без стрелочек
        link-arr = [1 to pages] 

    if pages > 9 && current-page <= 5 # стрелочку влево не отрисовываем
        link-arr = [1 to 9]
        right-chevron = a class:'icon item' href:'/admin/users/'+pages, i class:'right chevron icon'

    if pages > 9 && current-page > 5 && pages > current-page + 4 # отрисовываем обе стрелочки
        link-arr = [(current-page - 4) to (current-page + 4)]
        left-chevron  = a class:'icon item' href:'/admin/users/1', i class:'left chevron icon'
        right-chevron = a class:'icon item' href:'/admin/users/'+pages, i class:'right chevron icon'

    if pages > 9 && current-page > 5 && pages <= current-page + 4 # стрелочку вправо не отрисовываем
        link-arr = [(pages - 8) to pages]
        left-chevron  = a class:'icon item' href:'/admin/users/1', i class:'left chevron icon'

    get-link=-> a class:"item #{if address-last! ~= it => \active }" href:"/admin/users/#it", it

    div class:'ui right floated pagination menu',
        left-chevron
        map get-link, link-arr
        right-chevron
